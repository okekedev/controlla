using System;
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

            // Check for admin privileges
            if (_networkManager.NeedsAdministratorPrivileges)
            {
                AdminWarning.Visibility = Visibility.Visible;
            }

            // Start receiver automatically
            StartReceiver();
        }

        private async void ToggleButton_Click(object sender, RoutedEventArgs e)
        {
            if (_networkManager.IsReceiving)
            {
                await StopReceiver();
            }
            else
            {
                await StartReceiver();
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
                StatusText.Text = status;
                UpdateUI();
            });
        }

        private void UpdateUI()
        {
            if (_networkManager.IsReceiving)
            {
                ToggleButton.Content = "Stop Receiver";

                if (_networkManager.IsControllerConnected)
                {
                    StatusIndicator.Fill = new SolidColorBrush(Colors.LimeGreen);
                    ConnectionText.Text = "✓ Controller connected";
                }
                else
                {
                    StatusIndicator.Fill = new SolidColorBrush(Colors.Orange);
                    ConnectionText.Text = "Waiting for controller...";
                }
            }
            else
            {
                ToggleButton.Content = "Start Receiver";
                StatusIndicator.Fill = new SolidColorBrush(Colors.Gray);
                ConnectionText.Text = "No controller connected";
            }
        }

        protected override async void OnClosed(EventArgs e)
        {
            await _networkManager.StopAll();
            base.OnClosed(e);
        }
    }
}
