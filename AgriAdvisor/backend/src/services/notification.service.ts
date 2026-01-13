import { Injectable } from 'nestjs/common';
import { Notification } from '../models/notification.model';

@Injectable()
export class NotificationService {
    async createNotification(notificationData: any): Promise<Notification> {
        const notification = new Notification(notificationData);
        return await notification.save();
    }

    async getNotifications(userId: string): Promise<Notification[]> {
        return await Notification.find({ userId }).exec();
    }

    async deleteNotification(notificationId: string): Promise<void> {
        await Notification.findByIdAndDelete(notificationId).exec();
    }
}