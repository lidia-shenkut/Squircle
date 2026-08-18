# Implementation Plan: Squircle App

## Overview

This plan breaks the Squircle Flutter + Firebase app into incremental coding tasks, building from the project scaffold and core infrastructure through each feature module, and wiring everything together at the end. Each task references the specific requirements it satisfies and the correctness properties it validates. Tasks marked with `*` are property-based tests.

## Task Dependency Graph

```json
{
  "waves": [
    { "wave": 1, "tasks": ["1"] },
    { "wave": 2, "tasks": ["2"] },
    { "wave": 3, "tasks": ["3"] },
    { "wave": 4, "tasks": ["4"] },
    { "wave": 5, "tasks": ["5", "6", "7", "9", "10", "11", "12"] },
    { "wave": 6, "tasks": ["8", "13"] },
    { "wave": 7, "tasks": ["14"] },
    { "wave": 8, "tasks": ["15"] }
  ]
}
```

## Tasks

- [ ] 1. Project scaffold and core infrastructure
  - Initialize Flutter project with feature-first folder structure (`lib/core/`, `lib/features/`)
  - Add all required dependencies to `pubspec.yaml`: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `firebase_database`, `go_router`, `flutter_riverpod`, `riverpod_annotation`, `mocktail`, `connectivity_plus`, `mime`, `image_picker`, `file_picker`, `intl`
  - Configure Firebase (`google-services.json` / `GoogleService-Info.plist`) and initialize in `main.dart` with `ProviderScope`
  - Set up `go_router` with `ShellRoute` for bottom-navigation and define all named routes for every feature screen
  - Create app theme, color palette, and typography in `lib/core/theme/`
  - Implement `FirebaseErrorMapper` utility mapping all Firebase error codes to user-facing messages (email-already-in-use, phone-already-in-use, user-not-found, wrong-password, network-request-failed, permission-denied, storage/unauthorized)
  - Implement shared date helpers, string validators, and file validation utilities in `lib/core/utils/`
  - Write Firestore Security Rules covering all collections: `users`, `usernames`, `groups`, `groups/*/messages`, `groups/*/memory_posts`, `groups/*/events`, `groups/*/mood_checkins`, `groups/*/game_sessions`, `groups/*/analytics`, `streaks`, `notification_prefs`
  - Enable Firestore offline persistence in app initialization
  - Add `connectivity_plus` offline banner widget to root scaffold
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_


- [ ] 2. Authentication feature
  - [ ] 2.1 Implement `AuthRepository` abstract class and `FirebaseAuthRepository`
    - Cover `registerWithEmail`, `registerWithPhone`, `signInWithEmail`, `signOut`, `sendPasswordResetEmail`, and `authStateChanges` stream
    - Implement client-side `EmailValidator` (RFC 5322 simplified) and `PhoneValidator` (E.164 pattern `^\+[1-9]\d{1,14}$`) in `lib/core/utils/validators.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.7, 1.8, 1.9, 1.10_

  - [ ]* 2.2 Write property tests for email and phone format validation
    - Generate valid and invalid email strings; assert `EmailValidator` accepts only RFC 5322-conforming inputs
    - Generate valid and invalid E.164 strings; assert `PhoneValidator` accepts only E.164-conforming inputs
    - Minimum 100 iterations each
    - **Property 1: Email and Phone Format Validation — Validates: Requirements 1.3**

  - [ ]* 2.3 Write property test for duplicate credential rejection
    - Register a credential, then attempt to register again with the same credential; assert the second attempt is rejected and no duplicate account is created
    - **Property 2: Duplicate Credential Rejection — Validates: Requirements 1.4, 1.5**

  - [ ] 2.4 Implement `AuthProvider` (Riverpod) and `AuthState`
    - Expose `authStateChanges` as a `StreamProvider<User?>`; define `AuthState` sealed class (unauthenticated, authenticated, loading)
    - Add auth guard redirect logic to `go_router`
    - _Requirements: 1.7, 1.9_

  - [ ] 2.5 Build Login, Register, and Password Reset screens
    - Implement form validation using validators from 2.1; wire to `AuthRepository` via provider
    - Show verification-sent confirmation screen after registration
    - Display `FirebaseErrorMapper` messages on failure
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 1.10_


- [ ] 3. Profile and avatar feature
  - [ ] 3.1 Implement `ProfileRepository` abstract class and `FirestoreProfileRepository`
    - Cover `createProfile`, `updateProfile`, `isUsernameAvailable` (using `usernames/{username}` lookup collection), `getProfile`, `deleteAccount`
    - Write `usernames/{username}` document atomically with the `users/{uid}` document on profile creation
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 14.6_

  - [ ]* 3.2 Write property test for username uniqueness
    - Register a username, then attempt to register the same username for a different user; assert the second attempt is rejected and the first owner's username is unchanged
    - **Property 3: Username Uniqueness — Validates: Requirements 2.2, 2.4**

  - [ ] 3.3 Implement `AvatarRepository` and avatar upload logic
    - Validate file MIME type (JPEG, PNG, WebP) and size (≤ 10 MB) before upload using `mime` package and `File.length()`
    - Upload to `avatars/{uid}/` path in Cloud Storage; update `avatar_url` and `avatar_type` in `users/{uid}`
    - Propagate updated avatar URL to all groups the user belongs to (update denormalized fields in recent messages if needed)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ]* 3.4 Write property test for avatar upload validation
    - Generate files with random sizes and MIME types; assert only JPEG/PNG/WebP files ≤ 10 MB are accepted
    - **Property 4: Avatar Upload Validation — Validates: Requirements 3.3, 3.4**

  - [ ] 3.5 Build onboarding screens: profile setup and avatar selection
    - Display name + username form with real-time uniqueness check
    - Avatar picker: grid of default avatars OR photo upload via `image_picker`
    - _Requirements: 2.1, 3.1, 3.2_

  - [ ] 3.6 Build profile edit screen
    - Allow updating display name, username, and avatar at any time
    - Show switch between photo mode and default avatar mode
    - _Requirements: 2.3, 2.4, 2.5, 3.5_


- [ ] 4. Squircle group creation feature
  - [ ] 4.1 Implement `GroupRepository` abstract class and `FirestoreGroupRepository`
    - Cover `createGroup`, `updateGroup`, `watchUserGroups`, `watchGroup`
    - On `createGroup`: validate name length (1–50 chars), generate unique `invite_code`, set `admin_uid` and `member_uids` to creator, write atomically
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [ ]* 4.2 Write property test for group name length invariant
    - Generate group names of lengths 0–100; assert only names with 1–50 characters are accepted
    - **Property 5: Group Name Length Invariant — Validates: Requirements 4.2**

  - [ ]* 4.3 Write property test for group creator membership invariant
    - Generate group creation requests; assert the resulting group always has the creator in `member_uids` and `admin_uid` equals the creator's UID
    - **Property 20: Group Creator Membership Invariant — Validates: Requirements 4.4**

  - [ ]* 4.4 Write property test for invite code uniqueness
    - Create N groups; assert all generated `invite_code` values are distinct
    - **Property 21: Invite Code Uniqueness — Validates: Requirements 4.5**

  - [ ] 4.5 Build group creation screen
    - Group name input with character counter, optional group icon upload, create button
    - Navigate to group home on success
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ] 4.6 Build group home screen and group list screen
    - Group list: show all groups the user belongs to via `watchUserGroups` stream
    - Group home: tab bar hosting Chat, Memory Wall, Events, Games, Analytics, Mood tabs
    - _Requirements: 4.7_


- [ ] 5. Group invite system
  - [ ] 5.1 Implement invite methods in `GroupRepository`
    - Add `joinGroupByCode`, `joinGroupByLink`, `generateInviteCode`, `revokeInviteCode`, `inviteByEmail`
    - `joinGroupByCode`: query `groups` collection where `invite_code == code` and `invite_link_active == true`; add user to `member_uids`
    - `revokeInviteCode`: set `invite_link_active = false` and clear `invite_code`
    - `inviteByEmail`: trigger a Cloud Function (or Firebase Extension) to send an invitation email
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

  - [ ]* 5.2 Write property test for invite code validity
    - Generate valid, revoked, and random codes; assert valid codes add the user, revoked/random codes are rejected
    - **Property 6: Invite Code Validity — Validates: Requirements 5.4, 5.6, 5.7**

  - [ ] 5.3 Build invite management screen
    - Display current invite code with copy button, share link button, regenerate button, revoke button
    - Input field to invite by email address
    - _Requirements: 5.1, 5.2, 5.3, 5.7_

  - [ ] 5.4 Build join group screen
    - Text field to enter invite code; validate and join on submit
    - Handle deep-link invite URLs via `go_router` redirect
    - _Requirements: 5.4, 5.5, 5.6_


- [ ] 6. Real-time group chat feature
  - [ ] 6.1 Implement `ChatRepository` abstract class and `FirestoreChatRepository`
    - Cover `watchMessages` (paginated stream), `sendMessage`, `addReaction`, `pinMessage`, `unpinMessage`, `watchPinnedMessages`, `uploadAttachment`
    - Validate attachment size ≤ 100 MB before upload; validate audio duration ≤ 5 min for voice notes
    - Enforce pinned message cap: reject `pinMessage` if 10 messages are already pinned
    - Call `StreakRepository.recordActivity` on every message send
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 6.10, 6.11_

  - [ ]* 6.2 Write property test for chat attachment size validation
    - Generate file sizes around the 100 MB boundary; assert only files ≤ 100 MB are accepted
    - **Property 7: Chat Attachment Size Validation — Validates: Requirements 6.5, 6.6**

  - [ ]* 6.3 Write property test for pinned message count invariant
    - Generate sequences of pin/unpin operations; assert pinned count never exceeds 10
    - **Property 8: Pinned Message Count Invariant — Validates: Requirements 6.7**

  - [ ] 6.4 Build chat screen
    - Message list with `ListView.builder` driven by `watchMessages` stream
    - Message bubble with sender avatar, display name, timestamp, emoji reactions
    - Input bar: text field, emoji picker, attachment picker (image/video), voice note recorder
    - Long-press message to react or pin (admin only)
    - Pinned messages banner/drawer accessible from app bar
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.7, 6.8, 6.10, 6.11_


- [ ] 7. Shared memory wall feature
  - [ ] 7.1 Implement `MediaRepository` abstract class and `FirestoreMediaRepository`
    - Cover `createMemoryPost`, `deleteMemoryPost`, `watchMemoryWall`, `addReaction`, `uploadMedia`, `downloadMedia`
    - Validate photo (JPEG/PNG/WebP ≤ 20 MB) and video (MP4/MOV ≤ 500 MB) before upload
    - Validate caption length ≤ 300 characters
    - Enforce author-only deletion (or admin) via Firestore Security Rules
    - Order `watchMemoryWall` query by `created_at` descending
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9_

  - [ ]* 7.2 Write property tests for memory post media validation
    - Generate photo files with random sizes and MIME types; assert only JPEG/PNG/WebP ≤ 20 MB accepted
    - Generate video files with random sizes and MIME types; assert only MP4/MOV ≤ 500 MB accepted
    - **Property 9: Memory Post Media Validation — Validates: Requirements 7.1, 7.2, 7.3, 7.4**

  - [ ]* 7.3 Write property test for caption length invariant
    - Generate captions of lengths 0–400 characters; assert only captions ≤ 300 characters are accepted
    - **Property 10: Memory Post Caption Length Invariant — Validates: Requirements 7.5**

  - [ ]* 7.4 Write property test for memory wall ordering
    - Generate posts with random timestamps; assert the returned list is in strictly descending `created_at` order
    - **Property 11: Memory Wall Ordering — Validates: Requirements 7.6**

  - [ ]* 7.5 Write property test for memory post author deletion exclusivity
    - Generate posts with random authors; assert only the author or admin can delete; other members are rejected
    - **Property 25: Memory Post Author Deletion Exclusivity — Validates: Requirements 7.9**

  - [ ] 7.6 Build memory wall screen
    - Vertical timeline feed of `MemoryPost` cards (photo/video thumbnail, caption, reactions, author, timestamp)
    - FAB to upload new post: pick photo/video, add caption, submit
    - Tap post to view full-screen with download button
    - Long-press own post to delete
    - _Requirements: 7.1, 7.5, 7.6, 7.7, 7.8, 7.9_


- [ ] 8. Streak system
  - [ ] 8.1 Implement `StreakRepository` abstract class and `FirestoreStreakRepository`
    - Cover `watchUserStreak`, `watchGroupStreak`, `recordActivity`
    - `recordActivity`: write/update `streaks/{uid}__{groupId}` document with today's date key; Cloud Functions handle the actual streak increment logic
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8_

  - [ ]* 8.2 Write property tests for streak monotonicity and reset
    - Generate sequences of active/inactive days; assert streak increments on consecutive active days and resets to zero after a missed day
    - **Property 12: Chat Streak Monotonicity and Reset — Validates: Requirements 8.1, 8.2**

  - [ ]* 8.3 Write property test for streak milestone badge award
    - Generate streak values 1–100; assert a badge is awarded at every positive multiple of 7 and not at other values
    - **Property 13: Streak Milestone Badge Award — Validates: Requirements 8.6**

  - [ ]* 8.4 Write property test for group XP accumulation
    - Generate streak day sequences; assert group XP equals active_days × 10 and never decreases
    - **Property 23: Group XP Accumulation — Validates: Requirements 8.7**

  - [ ] 8.5 Build streak display widget
    - Inline streak badge showing current streak count and flame icon for each user in the group
    - Group streak card showing group streak, XP total, and "everyone active" streak
    - User title badges ("Most Active", "Memory Keeper") displayed on profile and in chat
    - _Requirements: 8.6, 8.7, 8.8_


- [ ] 9. Event and planning system
  - [ ] 9.1 Implement `EventRepository` abstract class and `FirestoreEventRepository`
    - Cover `createEvent`, `updateEvent`, `cancelEvent`, `submitVote`, `watchUpcomingEvents`, `watchEvent`
    - Validate event title length (1–100 chars) and poll option count (2–10) on creation
    - `submitVote`: use Firestore transaction to overwrite the user's existing vote and update option `vote_count`
    - _Requirements: 9.1, 9.3, 9.4, 9.5, 9.8, 9.9_

  - [ ]* 9.2 Write property test for event title length invariant
    - Generate titles of lengths 0–150 characters; assert only titles with 1–100 characters are accepted
    - **Property 15: Event Title Length Invariant — Validates: Requirements 9.1**

  - [ ]* 9.3 Write property test for poll option count invariant
    - Generate polls with 0–15 options; assert only polls with 2–10 options are accepted
    - **Property 16: Poll Option Count Invariant — Validates: Requirements 9.3**

  - [ ]* 9.4 Write property test for poll vote integrity
    - Generate sequences of votes from the same and different users; assert each user has exactly one vote recorded and option counts equal distinct voter counts
    - **Property 14: Event Poll Vote Integrity — Validates: Requirements 9.4**

  - [ ] 9.5 Build events screen and event detail screen
    - Events list: upcoming events with countdown timers, sorted by `event_date` ascending
    - Event detail: title, date/time, countdown, poll with real-time vote results, cancel/edit controls for creator
    - Create event bottom sheet: title input, date/time picker, optional poll builder (add/remove options)
    - Optional calendar sync via `add_2_calendar` package
    - _Requirements: 9.1, 9.3, 9.4, 9.5, 9.8, 9.9_


- [ ] 10. Mini-games system
  - [ ] 10.1 Implement `GameRepository` abstract class and `FirestoreGameRepository`
    - Cover `startGameSession`, `submitAnswer`, `watchGameSession`, `getSessionResults`
    - Implement game logic helpers: random prompt selection for Truth or Dare, profile-based question generation for Who Knows Best, question bank for trivia, member selection for spin wheel (assert selected UID is in `member_uids`), random Memory_Post selection for Guess the Photo
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

  - [ ]* 10.2 Write property test for spin wheel member containment
    - Generate groups with random members; run spin wheel selection 100+ times; assert `target_uid` is always in `member_uids`
    - **Property 26: Spin Wheel Member Containment — Validates: Requirements 10.4**

  - [ ] 10.3 Build games hub screen
    - Grid of 5 game cards: Truth or Dare, Who Knows Who Best, Trivia, Spin Wheel, Guess the Photo
    - Each card shows game name, icon, and "Play" button
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ] 10.4 Build individual game session screens
    - Truth or Dare: display prompt, target member name, "Done" button
    - Who Knows Who Best: question card with multiple-choice answers, score tally
    - Trivia: question + 4 options, timer, live score leaderboard
    - Spin Wheel: animated wheel, selected member reveal, challenge prompt
    - Guess the Photo: display Memory_Post image, text input for guess, reveal screen
    - Results summary screen shown to all participants when session ends
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.7_


- [ ] 11. Friend analytics feature
  - [ ] 11.1 Implement `AnalyticsRepository` abstract class and `FirestoreAnalyticsRepository`
    - Cover `computeGroupAnalytics` and `watchGroupAnalytics`
    - `watchGroupAnalytics`: stream the `groups/{groupId}/analytics` document (written by Cloud Functions)
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [ ]* 11.2 Write property test for analytics ranking correctness
    - Generate groups with random message/media/streak counts; assert `most_active_uid` has the highest message count, `top_media_sender_uid` has the highest media count, `longest_streak_uid` has the highest streak, and members inactive for 14+ days appear in `ghost_member_uids`
    - **Property 22: Analytics Ranking Correctness — Validates: Requirements 11.1, 11.2, 11.3, 11.4**

  - [ ] 11.3 Build analytics screen
    - Stat cards: Most Active Member, Top Media Sender, Longest Streak Holder, Ghost Members, Total Memories
    - Each card shows member avatar, display name, and metric value
    - Ghost member list with subtle "👻" indicator
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_


- [ ] 12. Mood and check-in system
  - [ ] 12.1 Implement `MoodRepository` abstract class and `FirestoreMoodRepository`
    - Cover `submitMoodCheckIn`, `watchMoodFeed`, `addReaction`, `hasCheckedInToday`
    - `hasCheckedInToday`: query `mood_checkins` where `author_uid == uid` and `date_key == today`; reject second submission with informative error
    - Validate mood value is one of the 6 predefined states
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

  - [ ]* 12.2 Write property test for mood check-in daily uniqueness
    - Generate same-day and cross-day submission sequences; assert at most one check-in per user per group per calendar day
    - **Property 17: Mood Check-In Daily Uniqueness — Validates: Requirements 12.2, 12.3**

  - [ ]* 12.3 Write property test for mood state validity
    - Generate valid and invalid mood strings; assert only the 6 predefined values are accepted
    - **Property 24: Mood State Validity — Validates: Requirements 12.1**

  - [ ] 12.4 Build mood feed screen
    - List of today's mood check-ins from group members with emoji mood icon, display name, and reaction row
    - "How are you feeling?" prompt at top with 6 mood buttons; hidden after daily check-in is submitted
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_


- [ ] 13. Push notification system
  - [ ] 13.1 Implement `NotificationRepository` abstract class and `FirestoreNotificationRepository`
    - Cover `saveFcmToken`, `updatePreferences`, `getPreferences`
    - On app start: request notification permission, retrieve FCM token, save to `users/{uid}.fcm_tokens` array
    - Handle foreground FCM messages with in-app banner; background/terminated messages use system tray
    - _Requirements: 13.1, 13.2, 13.5_

  - [ ]* 13.2 Write property test for notification preference enforcement
    - Generate preference configs with various categories disabled; generate notification events; assert disabled categories are never delivered to the user
    - **Property 18: Notification Preference Enforcement — Validates: Requirements 13.3, 13.4**

  - [ ] 13.3 Build notification preferences screen
    - Per-group toggle list for each notification category: Chat Messages, Memory Posts, Events, Event Reminders, Streak Alerts, Game Sessions, Mood Check-ins
    - Persist changes to `notification_prefs/{uid}/groups/{groupId}`
    - _Requirements: 13.3, 13.4_


- [ ] 14. Cloud Functions backend
  - [ ] 14.1 Implement streak evaluation scheduled function
    - `onSchedule` daily at midnight UTC: for each `streaks` document, compare `chat_streak_last_active` with yesterday's date; if missed, reset `chat_streak` to 0 and send streak-broken notification
    - Evaluate group streak and "everyone active" streak on the same schedule
    - Award XP (+10) for each day the group streak is maintained
    - Award badges at streak milestones (multiples of 7)
    - Use date-based idempotency key to prevent double-processing on retries
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.6, 8.7, 8.9_

  - [ ] 14.2 Implement event reminder scheduled function
    - `onSchedule` every 15 minutes: query events where `event_date` is within 24h and `reminder_24h_sent == false`; send FCM notification and set flag to true
    - Same logic for 1-hour reminder with `reminder_1h_sent` flag
    - _Requirements: 9.6, 9.7_

  - [ ] 14.3 Implement notification fan-out triggered functions
    - `onDocumentCreated` for `groups/{groupId}/messages/{messageId}`: fan out FCM to all group members respecting `notification_prefs`
    - `onDocumentCreated` for `groups/{groupId}/memory_posts/{postId}`: fan out FCM to all group members
    - `onDocumentCreated` for `groups/{groupId}/events/{eventId}`: fan out FCM to all group members
    - `onDocumentCreated` for `groups/{groupId}/game_sessions/{sessionId}`: fan out FCM to all group members
    - `onDocumentCreated` for `groups/{groupId}/mood_checkins/{checkinId}`: fan out FCM to all group members
    - `onDocumentUpdated` for `groups/{groupId}` (member_uids changed): notify existing members of new join
    - Use batched Firestore writes (max 500 ops per batch) for all fan-out operations
    - _Requirements: 5.8, 7.10, 9.2, 10.6, 12.4, 13.1, 13.2_

  - [ ] 14.4 Implement analytics computation triggered function
    - `onSchedule` daily: for each group, compute `most_active_uid`, `top_media_sender_uid`, `longest_streak_uid`, `ghost_member_uids`, `total_memory_posts` and write to `groups/{groupId}/analytics`
    - Assign "Most Active" and "Memory Keeper" titles to qualifying users
    - _Requirements: 8.8, 11.1, 11.2, 11.3, 11.4, 11.5_

  - [ ] 14.5 Implement account deletion Cloud Function
    - On user deletion trigger: remove PII from `users/{uid}`, `usernames/{username}`, anonymize messages (replace `sender_display_name` with "Deleted User"), remove from all group `member_uids`
    - _Requirements: 14.6_


- [ ] 15. Integration, E2E tests, and final wiring
  - [ ] 15.1 Write Firestore Security Rules integration tests using Firebase Emulator Suite
    - Test member-only read/write access for all group subcollections
    - Test admin-only operations (pin message, update group)
    - Test cross-group isolation (member of group A cannot read group B)
    - Test author-only deletion for messages and memory posts
    - **Property 19: Group Content Access Control — Validates: Requirements 14.2**

  - [ ] 15.2 Write auth integration tests using Firebase Auth Emulator
    - Registration with email and phone, duplicate rejection, password reset flow
    - Session expiry and re-authentication requirement

  - [ ] 15.3 Write end-to-end test: registration and onboarding flow
    - New user registers → completes profile setup → selects avatar → lands on group list screen

  - [ ] 15.4 Write end-to-end test: group creation and invite join flow
    - User A creates group → copies invite code → User B enters code → both see each other in member list

  - [ ] 15.5 Write end-to-end test: chat message delivery
    - User A sends text message → User B receives it in real time → User B reacts with emoji

  - [ ] 15.6 Write end-to-end test: memory wall upload and display
    - User uploads photo with caption → post appears at top of memory wall → another member reacts

  - [ ] 15.7 Write end-to-end test: event creation and poll voting
    - User creates event with poll → second user votes → poll results update in real time

  - [ ] 15.8 Write end-to-end test: mood check-in daily limit
    - User submits mood check-in → check-in appears in feed → second submission on same day is rejected with error

  - [ ] 15.9 Final UI polish and accessibility pass
    - Ensure all interactive elements have semantic labels for screen readers
    - Verify color contrast ratios meet WCAG AA standards
    - Test on both iOS and Android simulators for layout correctness

## Notes

- All Cloud Functions should be implemented in TypeScript using the Firebase Functions v2 SDK.
- The Firebase Local Emulator Suite (Auth, Firestore, Storage, Functions) must be used for all integration and E2E tests to avoid hitting production quotas.
- Property-based tests (marked with `*`) use the `test` package with custom generators; each runs a minimum of 100 iterations.
- Tasks within a phase can be worked on in parallel where the dependency graph allows (e.g., tasks 6, 7, 9, 10, 11, 12 are all siblings under task 4 and can proceed concurrently).
- The MVP scope (Phase 1–4 of the roadmap) maps to tasks 1–9 and 13–14 in this plan. Tasks 10–12 cover Phase 5 features.
