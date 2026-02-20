import mongoose from "mongoose";

const taskSchema = new mongoose.Schema({

    title: {
        type: String,
        required: true,
        maxlength: 200,
        trim: true
    },

    description: {
        type: String,
        maxlength: 1000,
        default: null
    },

    status: {
        type: String,
        enum: ['PENDING', 'IN_PROGRESS', 'COMPLETED'],
        default: 'PENDING'
    },

    priority: {
        type: String,
        enum: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'],
        default: 'MEDIUM'
    },

    dueDate: {
        type: Date,
        default: null
    },

    categoryId: {
        type: String,
        required: true,
        ref: 'Category'
    },

    userId: {
        type: String,
        required: true,
        ref: 'User'
    },

    createdAt: {
        type: Date,
        default: Date.now
    },

    updatedAt: {
        type: Date,
        default: Date.now
    }

}, {
    timestamps: true,
    versionKey: false // elimina __v)
});

export default mongoose.model("Task", taskSchema);