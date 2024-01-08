# Links

[Design in Figma](https://www.figma.com/file/owAO4CAPTJdpM1BZU5JHv7/Tracker-(YP)?t=SZDLmkWeOPX4y6mp-0)

# Screencast

https://github.com/ulanoff/HabitsTrackerApp-ios/assets/94757687/f3360aa8-da00-4f43-8015-143d93ab7c07

# Purpose and Goals

The application helps users form useful habits and monitor their execution.

Application goals:

- Control habits by days of the week;
- View progress on habits.

# Brief Description

- The application consists of habit tracker cards created by the user. They can specify the name, category, and set a schedule. Emojis and colors can also be chosen to distinguish cards from each other.
- Cards are sorted by categories. Users can search and filter them.
- Using the calendar, users can see which habits are scheduled for a specific day.
- The app includes statistics reflecting user achievements, progress, and average values.

# Functional Requirements

## Onboarding

When the user first enters the application, they land on the onboarding screen.

**Onboarding Screen Contains:**

1. Splash screen;
2. Title and secondary text;
3. Page controls;
4. "Wow, That's Technology" button.

**Algorithms and Available Actions:**

1. Users can swipe right and left to switch between pages. Page controls change state when switching pages;
2. Pressing the "Wow, That's Technology" button takes the user to the main screen.

## Creating a Habit Card

On the main screen, the user can create a tracker for a habit or irregular event. A habit is an event that repeats at a certain frequency. An irregular event is not tied to specific days.

**Habit Tracker Creation Screen Contains:**

1. Screen title;
2. Field for entering the tracker name;
3. Category section;
4. Schedule settings section;
5. Emoji section;
6. Tracker color selection section;
7. "Cancel" button;
8. "Create" button.

**Irregular Event Tracker Creation Screen Contains:**

1. Screen title;
2. Field for entering the tracker name;
3. Category section;
4. Emoji section;
5. Tracker color selection section;
6. "Cancel" button;
7. "Create" button.

**Algorithms and Available Actions:**

1. Users can create a habit or irregular event tracker. The algorithm for creating trackers is similar, but the irregular event lacks the schedule section.
2. Users can enter the tracker name;
    1. After entering one character, a delete icon appears. Clicking on the icon allows users to delete the entered text;
    2. Maximum character limit – 38;
    3. If the user exceeds the limit, an error message appears;
3. Pressing the "Category" section opens the category selection screen;
    1. If the user has not added categories before, a placeholder is displayed;
    2. The last selected category is marked with a blue checkmark;
    3. Clicking "Add Category" allows users to add a new one.
        1. A screen with a field for entering the category name opens; the "Done" button is inactive until at least 1 character is entered;
        2. If at least 1 character is entered, the "Done" button becomes active;
        3. Clicking "Done" closes the category creation screen, and users return to the category selection screen. The created category appears in the list without automatic selection or checkmark setting.
        4. Clicking on a category marks it with a blue checkmark, and users return to the habit creation screen. The selected category is displayed under the "Category" heading;
4. In habit creation mode, there is a "Schedule" section. Clicking on the section opens a screen with the selection of days of the week. Users can switch the switcher to choose the habit repetition day;
    1. Clicking "Done" returns users to the habit creation screen. The selected days are displayed on the habit creation screen under the "Schedule" heading;
        1. If users select all days, the text "Every day" is displayed;
5. Users can choose an emoji. A background appears under the selected emoji;
6. Users can choose the tracker color. An outline appears on the selected color;
7. Clicking the "Cancel" button allows users to stop habit creation;
8. The "Create" button is inactive until all sections are filled. Clicking the button opens the main screen. The created habit is displayed in the corresponding category;

## Main Screen

On the main screen, the user can view all created trackers for the selected date, edit them, and view statistics.

**The main screen contains:**

1. "+" button to add a habit;
2. "Trackers" title;
3. Current date;
4. Search field for trackers;
5. Tracker cards by categories. Cards include:
    1. Emoji;
    2. Tracker name;
    3. Number of tracked days;
    4. Button to mark the completed habit;
6. "Filter" button;
7. Tab bar.

**Algorithms and available actions:**

1. Pressing "+" opens a drawer with the option to create a habit or irregular event;
2. Pressing the date opens a calendar. Users can switch between months. Clicking on a date shows the trackers corresponding to that date;
3. Users can search for trackers by name in the search window;
    1. If nothing is found, the user sees a placeholder;
4. Pressing "Filters" opens a drawer with a list of filters;
    1. The filter button is absent if there are no trackers for the selected day;
    2. Choosing "All Trackers" shows all trackers for the selected day;
    3. Choosing "Today's Trackers" sets the current date, and users see all trackers for that day;
    4. Choosing "Completed" shows habits completed by the user on the selected day;
    5. Choosing "Uncompleted" shows uncompleted trackers for the selected day;
    6. The current filter is marked with a blue checkmark;
    7. Clicking on a filter hides the drawer, and the corresponding trackers are displayed on the screen;
        1. If nothing is found, the user sees a placeholder;
5. Scrolling up and down allows users to view the feed;
    1. If the card image hasn't loaded, a system loader is displayed;
6. Clicking on a card blurs the background, and a modal window appears;
    1. Users can pin the card. The card goes into the "Pinned" category at the top of the list;
        1. Clicking again allows users to unpin the card;
        2. If there are no pinned cards, the "Pinned" category is absent;
    2. Users can edit the card. A modal window appears with functionality similar to creating a card;
    3. Clicking "Delete" shows an action sheet.
        1. Users can confirm card deletion. All data related to it should be removed;
        2. Users can cancel and return to the main screen;
7. Using the tab bar, users can switch between the "Trackers" and "Statistics" sections.

## Editing and Deleting a Category

While creating a tracker, the user can edit categories in the list or delete unnecessary ones.

**Algorithms and available actions:**

1. Long-pressing a category in the list blurs the background and shows a modal window;
    1. Clicking "Edit" shows a modal window. Users can edit the category name. Clicking the "Done" button returns users to the category list;
    2. Clicking "Delete" shows an action sheet.
        1. Users can confirm category deletion. All data related to it should be removed;
        2. Users can cancel the action. After confirmation or cancellation, users return to the category list;

## Statistics

In the statistics tab, users can view successful indicators, their progress, and average values.

**The statistics screen contains:**

1. "Statistics" title;
2. List with statistical indicators. Each indicator includes:
    1. A numerical title;
    2. Secondary text with the indicator name;
3. Tab bar.

**Algorithms and available actions:**

1. If there is no data for any indicator, the user sees a placeholder;
2. If there is data for at least one indicator, statistics are displayed. Indicators without data are displayed with a zero value;
3. Users can view statistics for the following indicators:
    1. "Best Streak" calculates the maximum number of consecutive days without a break for all trackers;
    2. "Perfect Days" calculates the days when all planned habits were completed;
    3. "Trackers Completed" calculates the total number of completed habits over time;
    4. "Average Value" calculates the average number of habits completed in 1 day.

## Dark Theme

The app includes a dark theme that changes depending on the device system settings.

# Non-functional Requirements

1. The app should support iPhone X and above and be adapted for iPhone SE. The minimum supported iOS version is 13.4;
2. The app uses the standard iOS font – SF Pro.
3. Core Data is used to store habit data.
