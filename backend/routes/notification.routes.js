const express = require("express");
const router = express.Router();

const notificationController =
require("../controllers/notification.controller");

const { auth } =
require("../middleware/auth.middleware");

router.post(
    "/register-token",
    auth,
    notificationController.saveFcmToken
);

router.get(
    "/",
    auth,
    notificationController.getNotifications
);

router.put(
    "/:id/read",
    auth,
    notificationController.markAsRead
);

router.get(
    "/unread-count",
    auth,
    notificationController.getUnreadCount
);

module.exports = router;