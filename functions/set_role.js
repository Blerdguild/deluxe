const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

async function setUserRole() {
    try {
        const userId = 'KTewpNOF3iY4CU2sJLSWMpU00Si2';

        await db.collection('users').doc(userId).set({
            role: 'farmer',
            email: 'kagiso.mako@gmail.com',
            displayName: 'Kagiso Mako',
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

        console.log('✅ User role set to farmer successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error setting user role:', error);
        process.exit(1);
    }
}

setUserRole();
