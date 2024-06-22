class Config{
  static const String appName = "Kidz Emporium";
  static const String apiURL = "192.168.1.103:4000";
  static const String registerAPI = "api/register";
  static const String loginAPI = "api/login";
  static const String getAllUsersAPI = "api/users";
  static const String sendTokenToBackend = "api/register-fcm-token";
  static const String createNotification = "api/notification/send";

  //reminder
  static const String createReminderAPI = "api/reminder";
  static const String getReminderAPI = "api/get-reminder";
  static const String deleteReminderAPI = "api/delete-reminder";
  static const String getReminderDetailsAPI = "api/get-reminder-details";
  static const String updateReminderAPI = "api/update-reminder";

  //child
  static const String createChildAPI = "api/child";
  static const String getChildAPI = "api/get-child";
  static const String deleteChildAPI = "api/delete-child";
  static const String getChildDetailsAPI = "api/get-child-details";
  static const String updateChildAPI = "api/update-child";
  static const String getAllChildrenAPI = "api/children";

  //therapist
  static const String createTherapistAPI = "api/therapist";
  static const String getTherapistAPI = "api/get-therapist";
  static const String deleteTherapistAPI = "api/delete-therapist";
  static const String getTherapistDetailsAPI = "api/get-therapist-details";
  static const String updateTherapistAPI = "api/update-therapist";
  static const String getAllTherapistsAPI = "api/therapists";
  static const String checkTherapistAvailability = "api/check-therapist-availability";
  static const String getAvailableTherapist = "api/get-available-therapist";

  //booking
  static const String createBookingAPI = "api/booking";
  static const String getBookingAPI = "api/get-booking";
  static const String deleteBookingAPI = "api/delete-booking";
  static const String getBookingDetailsAPI = "api/get-booking-details";
  static const String updateBookingAPI = "api/update-booking";
  static const String getAllBookingsAPI = "api/bookings";

  //payment
  static const String createPaymentAPI = "api/payment";
  static const String getPaymentAPI = "api/get-payment";
  static const String deletePaymentAPI = "api/delete-payment";
  static const String getPaymentDetailsAPI = "api/get-payment-details";
  static const String updatePaymentAPI = "api/update-payment";
  static const String getAllPaymentsAPI = "api/payments";

  //report
  static const String createReportAPI = "api/report";
  static const String getReportAPI = "api/get-report";
  static const String deleteReportAPI = "api/delete-report";
  static const String getReportDetailsByBookingIdAPI = "api/get-report-details-by-bookingId";
  static const String updateReportAPI = "api/update-report";
  static const String getAllReportsAPI = "api/reports";
  static const String checkReportAPI = "api/check-report";
  static const String getReportDetailsAPI = "api/get-report-details";

  //task
  static const String createTaskAPI = "api/task";
  static const String getTaskAPI = "api/get-task";
  static const String deleteTaskAPI = "api/delete-task";
  static const String getTaskDetailsAPI = "api/get-task-details";
  static const String updateTaskAPI = "api/update-task";
  static const String getAllTasksAPI = "api/tasks";

  //livestream
  static const String createLivestreamAPI = "api/livestream";
  static const String getLivestreamAPI = "api/get-livestream";
  static const String deleteLivestreamAPI = "api/delete-livestream";
  static const String getLivestreamDetailsAPI = "api/get-livestream-details";
  static const String updateLivestreamAPI = "api/update-livestream";
  static const String getAllLivestreamsAPI = "api/livestreams";
  static const String getLivestreamDetailsByBookingIdAPI = "api/get-livestream-details-by-bookingId";

  //video
  static const String createVideoAPI = "api/video";
  static const String getVideoAPI = "api/get-video";
  static const String deleteVideoAPI = "api/delete-video";
  static const String getVideoDetailsAPI = "api/get-video-details";
  static const String updateVideoAPI = "api/update-video";
  static const String getAllVideosAPI = "api/videos";
}