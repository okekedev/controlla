using System;
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

        public MainWindow()
        {
            InitializeComponent();

            _networkManager = new NetworkManager();
            _networkManager.StatusChanged += OnStatusChanged;

            // Start receiver automatically
            _ = StartReceiver();
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
