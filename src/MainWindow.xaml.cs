using System;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;

namespace WorldClock
{
    public partial class MainWindow : Window
    {
        public ObservableCollection<ClockItem> Clocks { get; set; } = new ObservableCollection<ClockItem>();

        private readonly DispatcherTimer _clockTimer;
        private bool _isPinned = true;

        // In-Place Form State
        private ClockItem? _editingItem = null;
        private bool _isFormActive = false;

        // Move by Press & Drag State
        private bool _isDragging = false;
        private ClockItem? _draggedItem = null;
        private Border? _draggedBorder = null;
        private Point _dragStartPoint;

        public MainWindow()
        {
            InitializeComponent();

            // Load saved clocks or defaults
            var saved = ClockHelper.LoadClocks();
            foreach (var item in saved)
            {
                Clocks.Add(item);
            }
            CardsItemsControl.ItemsSource = Clocks;

            // Timer for real-time updates every second
            _clockTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            _clockTimer.Tick += (s, e) => UpdateAllClocks();
            _clockTimer.Start();

            // Initial view
            ShowCardsListView();
            UpdateAllClocks();
        }

        private void UpdateAllClocks()
        {
            if (_isFormActive) return;

            foreach (var item in Clocks)
            {
                var (time, date) = ClockHelper.GetCurrentTimeAndDate(item);
                item.CurrentTime = time;
                item.CurrentDate = date;
            }
        }

        // ==========================================
        // SINGLE-SCREEN IN-PLACE VIEW SWITCHERS
        // ==========================================
        private void ShowCardsListView()
        {
            _isFormActive = false;
            _editingItem = null;

            FormViewContainer.Visibility = Visibility.Collapsed;
            CardsScrollViewer.Visibility = Visibility.Visible;
            FooterBar.Visibility = Visibility.Visible;

            HeaderIcon.Text = "🌍";
            HeaderTitle.Text = "World Clock";

            UpdateAllClocks();
        }

        private void ShowInPlaceEditForm(ClockItem item)
        {
            _isFormActive = true;
            _editingItem = item;

            CardsScrollViewer.Visibility = Visibility.Collapsed;
            FooterBar.Visibility = Visibility.Collapsed;
            FormViewContainer.Visibility = Visibility.Visible;

            HeaderIcon.Text = "✏️";
            HeaderTitle.Text = "Edit Clock";
            FormModeTitle.Text = $"Edit Country: {item.Country}";

            // PRE-FILL WITH SELECTED CARD'S EXISTING DATA!
            _isAutoFilling = true;
            TxtCountry.Text = item.Country;
            TxtCity.Text = item.City;
            TxtTz.Text = item.TimeZoneInput;
            TxtCode.Text = item.DisplayCode;
            _isAutoFilling = false;

            BtnDelete.Visibility = Visibility.Visible;
            BtnSave.Content = "✓ Save";
        }

        private void ShowInPlaceAddForm()
        {
            _isFormActive = true;
            _editingItem = null;

            CardsScrollViewer.Visibility = Visibility.Collapsed;
            FooterBar.Visibility = Visibility.Collapsed;
            FormViewContainer.Visibility = Visibility.Visible;

            HeaderIcon.Text = "➕";
            HeaderTitle.Text = "Add Clock";
            FormModeTitle.Text = "Add New Country";

            // Completely clean inputs for new entry - NO stuck values!
            _isAutoFilling = true;
            TxtCountry.Text = "";
            TxtCity.Text = "";
            TxtTz.Text = "";
            TxtCode.Text = "";
            _isAutoFilling = false;

            BtnDelete.Visibility = Visibility.Collapsed;
            BtnSave.Content = "✓ Add";
        }

        // ==========================================
        // AUTO-DETECT LOCATION & TIMEZONE AS YOU TYPE
        // ==========================================
        private bool _isAutoFilling = false;

        private void TxtCountry_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (_isAutoFilling) return;

            string countryText = TxtCountry.Text.Trim();

            // When country is cleared or empty -> IMMEDIATELY clean all fields!
            // No previous country's details remain stuck!
            if (string.IsNullOrWhiteSpace(countryText))
            {
                _isAutoFilling = true;
                TxtCity.Text = "";
                TxtTz.Text = "";
                TxtCode.Text = "";
                _isAutoFilling = false;
                return;
            }

            var preset = ClockHelper.FindPreset(countryText);
            if (preset != null)
            {
                _isAutoFilling = true;
                try
                {
                    TxtCity.Text = preset.City;
                    TxtTz.Text = preset.TimeZone;
                    TxtCode.Text = preset.Code;
                }
                finally
                {
                    _isAutoFilling = false;
                }
            }
            // Note: If preset is null (e.g. user adds "/Qatar" or custom suffix),
            // we NEVER wipe out already filled details! Everything stays intact.
        }

        private void TxtCity_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (_isAutoFilling) return;

            string cityText = TxtCity.Text.Trim();
            if (string.IsNullOrWhiteSpace(cityText) || cityText.Length < 2) return;

            var preset = ClockHelper.FindPreset(cityText);
            if (preset != null)
            {
                _isAutoFilling = true;
                try
                {
                    if (string.IsNullOrWhiteSpace(TxtCountry.Text))
                    {
                        TxtCountry.Text = preset.Country;
                    }
                    TxtTz.Text = preset.TimeZone;
                    TxtCode.Text = preset.Code;
                }
                finally
                {
                    _isAutoFilling = false;
                }
            }
        }

        // ==========================================
        // FORM ACTION BUTTON HANDLERS
        // ==========================================
        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(TxtCountry.Text))
            {
                MessageBox.Show("Please enter a Country or City Name.", "Missing Information", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            string country = TxtCountry.Text.Trim();
            string city = string.IsNullOrWhiteSpace(TxtCity.Text) ? "" : TxtCity.Text.Trim();

            // Auto-resolve preset if timezone was not manually edited
            var preset = ClockHelper.FindPreset(country);
            if (preset == null && !string.IsNullOrWhiteSpace(city))
            {
                preset = ClockHelper.FindPreset(city);
            }

            string tz = string.IsNullOrWhiteSpace(TxtTz.Text) || TxtTz.Text == "+00:00"
                ? (preset != null ? preset.TimeZone : "+00:00")
                : TxtTz.Text.Trim();

            string code = string.IsNullOrWhiteSpace(TxtCode.Text) || TxtCode.Text == "UTC"
                ? (preset != null ? preset.Code : "")
                : TxtCode.Text.Trim();

            if (_editingItem != null)
            {
                // Update existing
                _editingItem.Country = country;
                _editingItem.City = city;
                _editingItem.TimeZoneInput = tz;
                _editingItem.DisplayCode = code;
            }
            else
            {
                // Add new
                var newItem = new ClockItem
                {
                    Flag = "",
                    Country = country,
                    City = city,
                    TimeZoneInput = tz,
                    DisplayCode = code
                };
                Clocks.Add(newItem);
            }

            ClockHelper.SaveClocks(Clocks);
            ShowCardsListView();
        }

        private void BtnDelete_Click(object sender, RoutedEventArgs e)
        {
            if (_editingItem != null)
            {
                Clocks.Remove(_editingItem);
                ClockHelper.SaveClocks(Clocks);
            }
            ShowCardsListView();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            ShowCardsListView();
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            ShowInPlaceAddForm();
        }

        // ==========================================
        // ONLY HEADER BAR IS DRAGGABLE FOR WINDOW
        // ==========================================
        private void Header_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                DragMove();
            }
        }

        // ==========================================
        // CARD INTERACTION: MOVE BY PRESS (NO BUTTONS, SAFE ENDDRAG)
        // ==========================================
        private void Card_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            var border = sender as Border;
            var item = border?.DataContext as ClockItem;
            if (item == null || border == null) return;

            // 1. DOUBLE CLICK: Open In-Place Edit Mode
            if (e.ClickCount == 2)
            {
                EndDrag();
                ShowInPlaceEditForm(item);
                return;
            }

            // 2. PRESS DOWN: Initiate Card Movement
            _isDragging = true;
            _draggedItem = item;
            _draggedBorder = border;
            _dragStartPoint = e.GetPosition(this);

            border.BorderBrush = new SolidColorBrush(Color.FromRgb(56, 189, 248));
            border.Background = new SolidColorBrush(Color.FromRgb(39, 42, 56));
        }

        private void Card_MouseMove(object sender, MouseEventArgs e)
        {
            if (!_isDragging || _draggedItem == null) return;

            if (e.LeftButton != MouseButtonState.Pressed)
            {
                EndDrag();
                return;
            }

            Point currentPoint = e.GetPosition(this);
            double deltaY = currentPoint.Y - _dragStartPoint.Y;

            int currentIndex = Clocks.IndexOf(_draggedItem);
            if (currentIndex < 0) return;

            const double MoveThreshold = 28.0;

            // Move UP by press
            if (deltaY < -MoveThreshold && currentIndex > 0)
            {
                Clocks.Move(currentIndex, currentIndex - 1);
                _dragStartPoint = currentPoint;
                ClockHelper.SaveClocks(Clocks);
            }
            // Move DOWN by press
            else if (deltaY > MoveThreshold && currentIndex < Clocks.Count - 1)
            {
                Clocks.Move(currentIndex, currentIndex + 1);
                _dragStartPoint = currentPoint;
                ClockHelper.SaveClocks(Clocks);
            }
        }

        private void Card_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            EndDrag();
        }

        private void Card_MouseLeave(object sender, MouseEventArgs e)
        {
            if (e.LeftButton != MouseButtonState.Pressed)
            {
                EndDrag();
            }
        }

        private void EndDrag()
        {
            try
            {
                if (_draggedBorder != null)
                {
                    _draggedBorder.BorderBrush = new SolidColorBrush(Color.FromRgb(46, 49, 61));
                    _draggedBorder.Background = new SolidColorBrush(Color.FromRgb(32, 34, 43));
                }
            }
            catch { }
            finally
            {
                _draggedBorder = null;
                _isDragging = false;
                _draggedItem = null;
            }
        }

        // ==========================================
        // PIN, MINIMIZE & CLOSE
        // ==========================================
        private void PinButton_Click(object sender, RoutedEventArgs e)
        {
            _isPinned = !_isPinned;
            this.Topmost = _isPinned;
            PinButton.Foreground = _isPinned
                ? new SolidColorBrush(Color.FromRgb(56, 189, 248))
                : new SolidColorBrush(Color.FromRgb(100, 116, 139));
            PinButton.Content = _isPinned ? "📌" : "📍";
        }

        private void MinimizeButton_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
