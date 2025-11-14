using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;

namespace AirControllaWindows
{
    /// <summary>
    /// Main window for AirControlla Windows receiver
    /// Mirrors the macOS ReceiverView
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly NetworkManager _networkManager;
        private bool _hasNetworkAccess = false;

        public MainWindow()
        {
            InitializeComponent();
            this.Title = "AirControlla for Windows"; // Set window title

            _networkManager = new NetworkManager();
            _networkManager.StatusChanged += OnStatusChanged;

            // Check initial network access and start
            _ = InitializeNetworkAccess();
        }

        private async Task InitializeNetworkAccess()
        {
            // Try to start the receiver - this will trigger Windows Firewall prompt if needed
            await StartReceiver();

            // Wait a moment for receiver to start
            await Task.Delay(500);

            // Check if receiver started successfully (means we have network access)
            _hasNetworkAccess = _networkManager.IsReceiving;
            UpdateNetworkAccessUI();
        }

        private async Task ConfigureFirewallAndStart()
        {
            try
            {
                // Start the receiver directly - this will trigger Windows Firewall prompt
                // when the app tries to bind to the network
                await StartReceiver();

                // Wait a moment for the receiver to start
                await Task.Delay(1000);

                // Check if we now have network access
                _hasNetworkAccess = _networkManager.IsReceiving;
                UpdateNetworkAccessUI();

                if (!_hasNetworkAccess)
                {
                    MessageBox.Show("Network access was not granted. Please click the toggle again and allow AirControlla in the Windows Firewall prompt.",
                        "Network Access Required", MessageBoxButton.OK, MessageBoxImage.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to start receiver: {ex.Message}",
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task StartReceiver()
        {
            try
            {
                await _networkManager.StartReceiver();
                UpdateUI();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to start receiver: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task StopReceiver()
        {
            try
            {
                await _networkManager.StopAll();
                UpdateUI();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to stop receiver: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void OnStatusChanged(object? sender, string status)
        {
            Dispatcher.Invoke(() =>
            {
                UpdateUI();
            });
        }

        private void UpdateUI()
        {
            if (_networkManager.IsReceiving)
            {
                if (_networkManager.IsControllerConnected)
                {
                    StatusIndicator.Fill = new SolidColorBrush(Colors.LimeGreen);
                    ConnectionText.Text = "Controller Connected";
                }
                else
                {
                    StatusIndicator.Fill = new SolidColorBrush(Colors.White);
                    ConnectionText.Text = "Waiting for Connection";
                }
            }
            else
            {
                StatusIndicator.Fill = new SolidColorBrush(Colors.Gray);
                ConnectionText.Text = "Not Started";
            }
        }

        private void UpdateNetworkAccessUI()
        {
            Dispatcher.Invoke(() =>
            {
                if (_hasNetworkAccess)
                {
                    // Green toggle - access allowed
                    ToggleBorder.Background = new SolidColorBrush(Color.FromArgb(128, 0, 255, 0)); // Semi-transparent green
                    ToggleCircle.HorizontalAlignment = HorizontalAlignment.Right;
                    ToggleCircle.Margin = new Thickness(0, 0, 3, 0);
                    NetworkStatusText.Text = "Allowed";
                }
                else
                {
                    // Red toggle - access denied
                    ToggleBorder.Background = new SolidColorBrush(Color.FromArgb(128, 255, 0, 0)); // Semi-transparent red
                    ToggleCircle.HorizontalAlignment = HorizontalAlignment.Left;
                    ToggleCircle.Margin = new Thickness(3, 0, 0, 0);
                    NetworkStatusText.Text = "Denied";
                }
            });
        }

        private async void NetworkToggle_Click(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            if (!_hasNetworkAccess)
            {
                // Try to enable network access - this will trigger the firewall prompt
                await ConfigureFirewallAndStart();
            }
            else
            {
                // Network access is already enabled
                MessageBox.Show("Network access is already enabled. To disable it, please remove the firewall rule from Windows Firewall settings.",
                    "Network Access", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private async void RefreshButton_Click(object sender, RoutedEventArgs e)
        {
            // Stop the receiver
            await StopReceiver();

            // Wait a moment before restarting
            await Task.Delay(500);

            // Restart the receiver
            await StartReceiver();
        }

        protected override async void OnClosed(EventArgs e)
        {
            await _networkManager.StopAll();
            base.OnClosed(e);
        }
    }
}
