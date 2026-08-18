# Requirements Document

## Introduction

Squircle is a private, invite-only social app designed for close friend groups. It combines real-time group chat, shared memory walls, streak-based engagement, event planning, mini-games, mood check-ins, and fun friend analytics into one unified mobile experience. Unlike public social media platforms, Squircle is entirely group-based and relationship-focused, providing a digital home for real friendships.

The MVP targets Flutter (cross-platform mobile) with Firebase as the backend (Authentication, Realtime Database, Cloud Storage, and Cloud Messaging for notifications).

## Glossary

- **Squircle**: The application itself; also the name for a private friend group within the app.
- **User**: A registered individual with an account on the Squircle platform.
- **Auth_Service**: The component responsible for user registration, login, and session management.
- **Profile_Service**: The component responsible for managing user profile data and avatars.
- **Avatar_Service**: The component responsible for avatar creation, selection, and customization.
- **Group_Service**: The component responsible for creating, managing, and joining Squircle groups.
- **Chat_Service**: The component responsible for real-time messaging within a Squircle group.
- **Memory_Wall**: The shared private media timeline within a Squircle group.
- **Media_Service**: The component responsible for uploading, storing, and retrieving photos and videos.
- **Streak_Service**: The component responsible for tracking and updating user and group streaks.
- **Event_Service**: The component responsible for creating, managing, and notifying group events.
- **Game_Service**: The component responsible for running mini-games within a Squircle group.
- **Analytics_Service**: The component responsible for computing and displaying friend analytics.
- **Mood_Service**: The component responsible for mood check-ins and reactions.
- **Notification_Service**: The component responsible for delivering push notifications to users.
- **Invite_Code**: A unique alphanumeric code that grants access to a specific Squircle group.
- **Streak**: A consecutive-day count of a user's or group's activity within a Squircle.
- **XP**: Experience points awarded to a group for collective activity milestones.
- **Memory_Post**: A single photo or video entry on the Memory Wall, with an optional caption.
- **Event**: A planned real-life meetup or activity created within a Squircle group.
- **Poll**: A decision-making tool within an Event for choosing time or location.

---

## Requirements

### Requirement 1: User Registration and Authentication

**User Story:** As a new user, I want to create an account using my email or phone number, so that I can access Squircle securely.

#### Acceptance Criteria

1. THE Auth_Service SHALL support account registration using a valid email address.
2. THE Auth_Service SHALL support account registration using a valid phone number.
3. WHEN a user submits a registration form, THE Auth_Service SHALL validate that the email address conforms to standard email format OR the phone number conforms to E.164 format before creating the account.
4. WHEN a user submits a registration form with an email address already associated with an existing account, THE Auth_Service SHALL return an error message indicating the email is already in use.
5. WHEN a user submits a registration form with a phone number already associated with an existing account, THE Auth_Service SHALL return an error message indicating the phone number is already in use.
6. WHEN a new account is successfully created, THE Auth_Service SHALL send a verification message to the provided email address or phone number.
7. WHEN a user submits valid credentials, THE Auth_Service SHALL authenticate the user and establish a session within 3 seconds.
8. WHEN a user submits invalid credentials, THE Auth_Service SHALL return an error message without revealing which specific field is incorrect.
9. WHEN an authenticated session expires, THE Auth_Service SHALL require the user to re-authenticate before accessing protected resources.
10. THE Auth_Service SHALL provide a password reset flow for email-based accounts.

---

### Requirement 2: User Profile

**User Story:** As a registered user, I want to set up and manage my profile, so that my friends can identify and connect with me.

#### Acceptance Criteria

1. THE Profile_Service SHALL require each user to provide a display name and a unique username during onboarding.
2. WHEN a user submits a username that is already taken, THE Profile_Service SHALL return an error and prompt the user to choose a different username.
3. THE Profile_Service SHALL allow a user to update their display name at any time.
4. THE Profile_Service SHALL allow a user to update their username at any time, subject to uniqueness validation.
5. THE Profile_Service SHALL allow a user to update their profile picture at any time.
6. WHEN a user updates their profile information, THE Profile_Service SHALL persist the changes within 2 seconds and reflect them across all active sessions.

---

### Requirement 3: Avatar Creation and Selection

**User Story:** As a user, I want to choose or create an avatar during signup, so that I have a visual identity within my friend groups.

#### Acceptance Criteria

1. WHEN a user completes registration, THE Avatar_Service SHALL present the user with the option to select a default avatar from a predefined set OR upload a personal photo.
2. WHEN a user selects a default avatar, THE Avatar_Service SHALL assign that avatar as the user's active avatar.
3. WHEN a user uploads a personal photo, THE Avatar_Service SHALL validate that the file is an image format (JPEG, PNG, or WebP) and does not exceed 10 MB before storing it.
4. IF a user uploads a file that is not a supported image format or exceeds 10 MB, THEN THE Avatar_Service SHALL return a descriptive error message and reject the upload.
5. THE Avatar_Service SHALL allow a user to switch between photo mode and default avatar mode at any time after signup.
6. WHEN a user updates their avatar, THE Avatar_Service SHALL propagate the updated avatar to all Squircle groups the user belongs to within 5 seconds.

---

### Requirement 4: Squircle Group Creation

**User Story:** As a user, I want to create a private friend group called a Squircle, so that I have a dedicated space to connect with my close friends.

#### Acceptance Criteria

1. THE Group_Service SHALL allow any authenticated user to create a new Squircle group.
2. WHEN a user creates a Squircle group, THE Group_Service SHALL require a group name of between 1 and 50 characters.
3. WHEN a user creates a Squircle group, THE Group_Service SHALL allow the user to optionally upload a group icon or avatar.
4. WHEN a Squircle group is created, THE Group_Service SHALL automatically add the creating user as the first member and group admin.
5. WHEN a Squircle group is created, THE Group_Service SHALL generate a unique Invite_Code for that group.
6. THE Group_Service SHALL allow a group admin to update the group name and group icon at any time.
7. THE Group_Service SHALL enforce that Squircle groups are not publicly discoverable; access is restricted to members and invited users only.

---

### Requirement 5: Group Invite System

**User Story:** As a group admin, I want to invite friends to my Squircle via email, link, or invite code, so that only trusted people can join.

#### Acceptance Criteria

1. THE Group_Service SHALL allow a group admin to generate a shareable invite link for the Squircle group.
2. THE Group_Service SHALL allow a group admin to generate or regenerate an alphanumeric Invite_Code for the Squircle group.
3. THE Group_Service SHALL allow a group admin to invite a user by email address, sending an invitation notification to that address.
4. WHEN a user enters a valid Invite_Code, THE Group_Service SHALL add the user to the corresponding Squircle group.
5. WHEN a user follows a valid invite link, THE Group_Service SHALL add the user to the corresponding Squircle group after authentication.
6. IF a user enters an invalid or expired Invite_Code, THEN THE Group_Service SHALL return an error message indicating the code is invalid or expired.
7. THE Group_Service SHALL allow a group admin to revoke an existing invite link or Invite_Code, rendering it inactive.
8. WHEN a new member joins a Squircle group, THE Notification_Service SHALL notify all existing group members.

---

### Requirement 6: Real-Time Group Chat

**User Story:** As a group member, I want to send and receive messages in real time within my Squircle, so that I can communicate with my friends instantly.

#### Acceptance Criteria

1. THE Chat_Service SHALL deliver text messages sent by a group member to all other online members within 1 second under normal network conditions.
2. THE Chat_Service SHALL support emoji characters in message content.
3. THE Chat_Service SHALL allow group members to react to any message using a predefined set of emoji reactions.
4. THE Chat_Service SHALL allow group members to share images and videos as message attachments.
5. WHEN a member sends a media attachment, THE Chat_Service SHALL validate that the file does not exceed 100 MB before uploading.
6. IF a media attachment exceeds 100 MB, THEN THE Chat_Service SHALL return an error message and reject the upload.
7. THE Chat_Service SHALL allow a group admin to pin up to 10 messages in a Squircle group.
8. WHEN a message is pinned, THE Chat_Service SHALL display pinned messages in a dedicated pinned messages section accessible to all group members.
9. WHEN a group member is offline, THE Chat_Service SHALL queue undelivered messages and deliver them when the member reconnects.
10. THE Chat_Service SHALL persist all messages so that members can scroll through the full chat history.
11. WHERE voice notes are enabled, THE Chat_Service SHALL allow group members to record and send audio messages up to 5 minutes in duration.

---

### Requirement 7: Shared Memory Wall

**User Story:** As a group member, I want to upload photos and videos to a shared memory wall, so that our group can preserve and revisit shared memories.

#### Acceptance Criteria

1. THE Media_Service SHALL allow any group member to upload photos (JPEG, PNG, WebP) and videos (MP4, MOV) to the group's Memory Wall.
2. WHEN a member uploads a photo, THE Media_Service SHALL validate that the file does not exceed 20 MB.
3. WHEN a member uploads a video, THE Media_Service SHALL validate that the file does not exceed 500 MB.
4. IF a media file exceeds the allowed size limit, THEN THE Media_Service SHALL return a descriptive error message and reject the upload.
5. THE Media_Service SHALL allow a member to add an optional text caption of up to 300 characters to a Memory_Post.
6. THE Media_Service SHALL display Memory_Posts in reverse-chronological order on the Memory Wall, forming a timeline.
7. THE Media_Service SHALL allow any group member to react to a Memory_Post using a predefined set of emoji reactions.
8. THE Media_Service SHALL allow any group member to download any media file from the Memory Wall to their device.
9. THE Media_Service SHALL allow the author of a Memory_Post to delete their own post at any time.
10. WHEN a new Memory_Post is uploaded, THE Notification_Service SHALL notify all group members.

---

### Requirement 8: Streak System

**User Story:** As a group member, I want to earn and maintain streaks for consistent activity, so that our group stays engaged and motivated.

#### Acceptance Criteria

1. THE Streak_Service SHALL track a daily chat streak for each user within each Squircle group, incrementing the streak count when the user sends at least one message on consecutive calendar days.
2. WHEN a user does not send any message in a Squircle group for a full calendar day, THE Streak_Service SHALL reset that user's daily chat streak for that group to zero.
3. THE Streak_Service SHALL track a group activity streak for a Squircle group, incrementing the streak count when at least one member sends a message on consecutive calendar days.
4. THE Streak_Service SHALL track an "everyone active" streak for a Squircle group, incrementing the streak count when all members send at least one message on the same calendar day.
5. THE Streak_Service SHALL track an event participation streak for each user, incrementing the streak count when the user marks attendance or votes in consecutive group events.
6. WHEN a streak milestone is reached (multiples of 7 days), THE Streak_Service SHALL award the relevant user or group a badge.
7. THE Streak_Service SHALL maintain a group XP total, awarding 10 XP per day the group activity streak is maintained.
8. THE Streak_Service SHALL assign titles to users based on activity thresholds: a user with the highest message count in a group SHALL receive the "Most Active" title, and a user with the most Memory_Posts in a group SHALL receive the "Memory Keeper" title.
9. WHEN a streak is broken, THE Notification_Service SHALL notify the affected user or group members within 1 hour of the streak expiry.

---

### Requirement 9: Event and Planning System

**User Story:** As a group member, I want to create and manage events within my Squircle, so that we can coordinate real-life meetups easily.

#### Acceptance Criteria

1. THE Event_Service SHALL allow any group member to create an Event with a title (1–100 characters), a date, and a time.
2. WHEN an Event is created, THE Notification_Service SHALL send a notification to all group members within 30 seconds.
3. THE Event_Service SHALL allow the Event creator to attach a Poll to the Event for deciding the meeting time or location, with between 2 and 10 options.
4. WHEN a group member submits a vote on a Poll, THE Event_Service SHALL record the vote and update the Poll results in real time.
5. THE Event_Service SHALL display a countdown timer showing the time remaining until each upcoming Event.
6. THE Event_Service SHALL send a reminder notification to all group members 24 hours before an Event's scheduled date and time.
7. THE Event_Service SHALL send a reminder notification to all group members 1 hour before an Event's scheduled date and time.
8. WHERE calendar sync is enabled by the user, THE Event_Service SHALL add the Event to the user's device calendar upon creation or RSVP.
9. THE Event_Service SHALL allow the Event creator to cancel or update an Event, triggering a notification to all group members.

---

### Requirement 10: Mini-Games System

**User Story:** As a group member, I want to play casual mini-games with my friends inside the Squircle, so that we can have fun and bond.

#### Acceptance Criteria

1. THE Game_Service SHALL provide a "Truth or Dare" game where a prompt is randomly selected from a predefined set and presented to a designated group member.
2. THE Game_Service SHALL provide a "Who Knows Who Best?" quiz where questions about group members are generated from profile data and answered by other members.
3. THE Game_Service SHALL provide a trivia quiz game where questions are drawn from a predefined question bank and presented to all group members simultaneously.
4. THE Game_Service SHALL provide a spin-wheel challenge game where a random group member is selected and assigned a challenge from a predefined set.
5. THE Game_Service SHALL provide a "Guess the Photo" game where a Memory_Post photo is displayed without attribution and group members submit guesses for who posted it.
6. WHEN a game session is initiated by a group member, THE Game_Service SHALL notify all other group members in the Squircle.
7. WHEN a game session ends, THE Game_Service SHALL display a results summary to all participating members.

---

### Requirement 11: Friend Analytics

**User Story:** As a group member, I want to see fun stats about my friend group, so that we can celebrate our activity and engagement.

#### Acceptance Criteria

1. THE Analytics_Service SHALL compute and display the most active member in a Squircle group, defined as the member with the highest total message count in the last 30 days.
2. THE Analytics_Service SHALL compute and display the top media sender in a Squircle group, defined as the member with the highest number of media messages sent in the last 30 days.
3. THE Analytics_Service SHALL display the longest current streak holder in a Squircle group.
4. THE Analytics_Service SHALL identify and display a "ghost member" indicator for any group member who has not sent a message or reacted to any content in the last 14 days.
5. THE Analytics_Service SHALL display the total number of Memory_Posts shared within a Squircle group.
6. WHEN analytics data is requested by a group member, THE Analytics_Service SHALL return the computed results within 5 seconds.

---

### Requirement 12: Mood and Check-In System

**User Story:** As a group member, I want to share my mood with my friends, so that we can stay emotionally connected even when we are not together.

#### Acceptance Criteria

1. THE Mood_Service SHALL allow any group member to submit a mood check-in by selecting from a predefined set of mood states (e.g., Happy, Sad, Excited, Tired, Anxious, Grateful).
2. THE Mood_Service SHALL allow a group member to submit one mood check-in per calendar day per Squircle group.
3. IF a group member attempts to submit a second mood check-in on the same calendar day for the same group, THEN THE Mood_Service SHALL reject the submission and inform the user that a check-in has already been recorded for today.
4. WHEN a mood check-in is submitted, THE Mood_Service SHALL display the check-in to all group members in the group's mood feed.
5. THE Mood_Service SHALL allow any group member to react to another member's mood check-in using a predefined set of supportive reactions.
6. THE Mood_Service SHALL make mood check-ins optional; a user's participation or non-participation SHALL NOT affect their streak counts or group XP.

---

### Requirement 13: Push Notifications

**User Story:** As a group member, I want to receive timely push notifications for important group activity, so that I stay informed without having to open the app constantly.

#### Acceptance Criteria

1. THE Notification_Service SHALL deliver push notifications to a user's device for the following events: new chat messages, new Memory_Posts, new Events, Event reminders, streak alerts, new game sessions, and new mood check-ins.
2. THE Notification_Service SHALL deliver push notifications within 30 seconds of the triggering event under normal network conditions.
3. THE Notification_Service SHALL allow a user to configure notification preferences per Squircle group, enabling or disabling specific notification categories.
4. WHEN a user has disabled notifications for a specific category in a specific group, THE Notification_Service SHALL NOT deliver notifications of that category for that group to the user.
5. WHEN a user's device is offline, THE Notification_Service SHALL queue notifications and deliver them when the device reconnects.

---

### Requirement 14: Data Privacy and Security

**User Story:** As a user, I want my data and my group's content to remain private and secure, so that only trusted friends can access our shared space.

#### Acceptance Criteria

1. THE Auth_Service SHALL enforce that all API endpoints require a valid authenticated session token before returning any user or group data.
2. THE Group_Service SHALL enforce that a user can only access the content of a Squircle group if they are a current member of that group.
3. THE Auth_Service SHALL transmit all data between the client and server over HTTPS/TLS.
4. THE Auth_Service SHALL store user passwords using a cryptographic hashing algorithm with a per-user salt; plaintext passwords SHALL NOT be stored.
5. THE Group_Service SHALL enforce that Squircle group content is not indexed or accessible via public search engines or external APIs.
6. THE Profile_Service SHALL allow a user to delete their account, which SHALL remove all personally identifiable information associated with that user from the platform within 30 days.
