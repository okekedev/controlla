using System;
using System.Net;
using System.Threading.Tasks;
using EmbedIO;
using EmbedIO.Actions;
using EmbedIO.WebApi;
using Zeroconf;
using Newtonsoft.Json.Linq;

namespace AirControllaWindows
{
    /// <summary>
    /// Handles network discovery (Bonjour/mDNS) and HTTP server for receiving commands from iPhone
    /// Mirrors the Swift NetworkManager from macOS version
    /// </summary>
    public class NetworkManager
    {
        private WebServer? _webServer;
        private IDisposable? _mdnsService;
        private const int Port = 8080;
        private const string ServiceType = "_controlla._tcp.local.";

        public bool IsReceiving { get; private set; }
        public string ReceiverStatus { get; private set; } = "Not Started";
        public bool IsControllerConnected { get; private set; }
        public bool NeedsAdministratorPrivileges { get; private set; }

        public event EventHandler<string>? StatusChanged;

        public NetworkManager()
        {
            CheckAdministratorPrivileges();
        }

        /// <summary>
        /// Check if app is running with administrator privileges (needed for input simulation)
        /// </summary>
        private void CheckAdministratorPrivileges()
        {
            var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
            var principal = new System.Security.Principal.WindowsPrincipal(identity);
            NeedsAdministratorPrivileges = !principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
        }

        /// <summary>
        /// Start the receiver: HTTP server + Bonjour advertising
        /// </summary>
        public async Task StartReceiver()
        {
            if (IsReceiving) return;

            try
            {
                UpdateStatus("Starting receiver...");

                // Start HTTP server
                await StartHttpServer();

                // Advertise service via Bonjour/mDNS
                await AdvertiseService();

                IsReceiving = true;
                UpdateStatus($"Listening on port {Port}");
            }
            catch (Exception ex)
            {
                UpdateStatus($"Error: {ex.Message}");
                Console.WriteLine($"❌ Failed to start receiver: {ex}");
            }
        }

        /// <summary>
        /// Stop receiver and clean up
        /// </summary>
        public async Task StopAll()
        {
            if (!IsReceiving) return;

            try
            {
                // Stop HTTP server
                if (_webServer != null)
                {
                    await _webServer.DisposeAsync();
                    _webServer = null;
                }

                // Stop mDNS advertising
                _mdnsService?.Dispose();
                _mdnsService = null;

                IsReceiving = false;
                IsControllerConnected = false;
                UpdateStatus("Stopped");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error stopping receiver: {ex}");
            }
        }

        /// <summary>
        /// Start HTTP server to receive commands from iPhone
        /// Mirrors the Swift NWListener implementation
        /// </summary>
        private async Task StartHttpServer()
        {
            string url = $"http://*:{Port}/";

            _webServer = new WebServer(o => o
                    .WithUrlPrefix(url)
                    .WithMode(HttpListenerMode.EmbedIO))
                .WithLocalSessionManager()
                .WithModule(new ActionModule("/", HttpVerbs.Post, HandleCommand))
                .WithModule(new ActionModule("/ping", HttpVerbs.Get, ctx => ctx.SendStringAsync("pong", "text/plain", System.Text.Encoding.UTF8)));

            await _webServer.StartAsync();
            Console.WriteLine($"✅ HTTP server started on {url}");
        }

        /// <summary>
        /// Handle incoming commands from iPhone
        /// Matches the Swift handleCommand implementation
        /// </summary>
        private async Task HandleCommand(IHttpContext context)
        {
            try
            {
                var body = await context.GetRequestBodyAsStringAsync();
                var json = JObject.Parse(body);
                var action = json["action"]?.ToString();

                Console.WriteLine($"📨 Received command: {action}");

                // Mark controller as connected when we receive first command
                if (!IsControllerConnected)
                {
                    IsControllerConnected = true;
                    UpdateStatus("Controller connected");
                }

                // Route to appropriate handler
                switch (action)
                {
                    case "move":
                        HandleMouseMove(json);
                        break;
                    case "click":
                        HandleMouseClick(json);
                        break;
                    case "type":
                        HandleType(json);
                        break;
                    case "key":
                        HandleKeyPress(json);
                        break;
                    case "voice":
                        HandleVoiceInput(json);
                        break;
                    default:
                        Console.WriteLine($"⚠️ Unknown action: {action}");
                        break;
                }

                await context.SendStringAsync("OK", "text/plain", System.Text.Encoding.UTF8);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error handling command: {ex}");
                context.Response.StatusCode = 500;
                await context.SendStringAsync($"Error: {ex.Message}", "text/plain", System.Text.Encoding.UTF8);
            }
        }

        // MARK: - Command Handlers

        private void HandleMouseMove(JObject json)
        {
            int deltaX = json["x"]?.Value<int>() ?? 0;
            int deltaY = json["y"]?.Value<int>() ?? 0;
            InputSimulator.MoveMouse(deltaX, deltaY);
        }

        private void HandleMouseClick(JObject json)
        {
            string button = json["button"]?.ToString() ?? "left";
            InputSimulator.ClickMouse(button);
        }

        private void HandleType(JObject json)
        {
            string text = json["text"]?.ToString() ?? "";
            InputSimulator.TypeText(text);
        }

        private void HandleKeyPress(JObject json)
        {
            byte keycode = json["keycode"]?.Value<byte>() ?? 0;
            byte modifier = json["modifier"]?.Value<byte>() ?? 0;
            InputSimulator.SendKeyPress(keycode, modifier);
        }

        private void HandleVoiceInput(JObject json)
        {
            string text = json["text"]?.ToString() ?? "";
            InputSimulator.TypeText(text);
        }

        /// <summary>
        /// Advertise service via Bonjour/mDNS so iPhone can discover this PC
        /// Mirrors the Swift NWListener.advertise() implementation
        /// </summary>
        private async Task AdvertiseService()
        {
            try
            {
                string hostname = Dns.GetHostName();
                string serviceName = $"AirControlla-{hostname}";

                // Advertise using Zeroconf
                _mdnsService = await ZeroconfResolver.BrowseDomainsAsync(ServiceType);

                Console.WriteLine($"✅ Advertising as: {serviceName}");
                Console.WriteLine($"   Service type: {ServiceType}");
                Console.WriteLine($"   Port: {Port}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to advertise service: {ex}");
            }
        }

        private void UpdateStatus(string status)
        {
            ReceiverStatus = status;
            StatusChanged?.Invoke(this, status);
        }
    }
}
