import mongoose from "mongoose";

const categorySchema = new mongoose.Schema({

    name: {
        type: String,
        required: true,
        maxlength: 50,
        trim: true
    },

    color: {
        type: String,
        required: true,
        match: /^#([0-9A-Fa-f]{6})$/
    },

    icon: {
        type: String,
        default: null
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

export default mongoose.model("Category", categorySchema);
