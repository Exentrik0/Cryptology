#include <iostream>
#include <string>
#include <cctype>

using namespace std;

string encrypt(string text, int shift) {
    string encrypted = "";
    
    for (char c : text) {
        if (isalpha(c)) {
            char base = isupper(c) ? 'A' : 'a';
            char shifted = (c - base + shift) % 26;
            if (shifted < 0) shifted += 26; // Handle negative shifts
            encrypted += (base + shifted);
        } else {
            encrypted += c; // Keep non-alphabetic characters unchanged
        }
    }
    
    return encrypted;
}

string decrypt(string text, int shift) {
    return encrypt(text, -shift); // Decryption is encryption with negative shift
}

int main() {
    string message;
    int shift;
    int choice;
    
    cout << "=== Shift Cipher (Caesar Cipher) ===" << endl;
    cout << "1. Encrypt" << endl;
    cout << "2. Decrypt" << endl;
    cout << "Enter your choice (1 or 2): ";
    cin >> choice;
    
    cin.ignore(); // Clear the input buffer
    
    cout << "Enter the message: ";
    getline(cin, message);
    
    cout << "Enter the shift value (0-25): ";
    cin >> shift;
    
    // Ensure shift is within valid range
    shift = shift % 26;
    
    if (choice == 1) {
        string encrypted = encrypt(message, shift);
        cout << "\nOriginal message: " << message << endl;
        cout << "Encrypted message: " << encrypted << endl;
    } else if (choice == 2) {
        string decrypted = decrypt(message, shift);
        cout << "\nEncrypted message: " << message << endl;
        cout << "Decrypted message: " << decrypted << endl;
    } else {
        cout << "Invalid choice!" << endl;
        return 1;
    }
    
    return 0;
}