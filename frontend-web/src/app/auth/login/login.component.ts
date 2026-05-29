import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, HttpClientModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {

  // ── Tab control ──────────────────────────────────────────────────
  activeTab: 'login' | 'register' = 'login';

  // ── Login form ───────────────────────────────────────────────────
  loginEmail    = '';
  loginPassword = '';
  rememberMe    = false;
  showLoginPass = false;

  // ── Register form ─────────────────────────────────────────────────
  registerUsername  = '';
  registerEmail     = '';
  registerPassword  = '';
  registerConfirm   = '';
  showRegPass       = false;
  showRegConfirm    = false;

  // ── State ─────────────────────────────────────────────────────────
  loading       = false;
  errorMessage  = '';
  successMessage = '';

  // ── API URL — change to your real endpoint ────────────────────────
  private apiUrl = 'http://localhost:3000/api/auth';   // ← ajusta aquí

  constructor(private http: HttpClient, private router: Router) {}

  // ─────────────────────────────────────────────────────────────────
  switchTab(tab: 'login' | 'register'): void {
    this.activeTab    = tab;
    this.errorMessage = '';
    this.successMessage = '';
  }

  // ─────────────────────────────────────────────────────────────────
  onLogin(): void {
    if (!this.loginEmail || !this.loginPassword) {
      this.errorMessage = 'Por favor, completa todos los campos.';
      return;
    }

    this.loading      = true;
    this.errorMessage = '';

    const body = {
      email:    this.loginEmail,
      password: this.loginPassword
    };

    this.http.post<{ token?: string; message?: string }>(`${this.apiUrl}/login`, body)
      .subscribe({
        next: (res) => {
          this.loading = false;
          if (res.token) {
            if (this.rememberMe) {
              localStorage.setItem('token', res.token);
            } else {
              sessionStorage.setItem('token', res.token);
            }
          }
          // Navigate to dashboard after successful login
          this.router.navigate(['/dashboard']);
        },
        error: (err) => {
          this.loading      = false;
          this.errorMessage = err.error?.error ?? 'Credenciales inválidas. Intenta de nuevo.';
        }
      });
  }

  // ─────────────────────────────────────────────────────────────────
  onRegister(): void {
    if (!this.registerUsername || !this.registerEmail || !this.registerPassword || !this.registerConfirm) {
      this.errorMessage = 'Por favor, completa todos los campos.';
      return;
    }
    if (this.registerPassword !== this.registerConfirm) {
      this.errorMessage = 'Las contraseñas no coinciden.';
      return;
    }

    this.loading      = true;
    this.errorMessage = '';

    const body = {
      name: this.registerUsername,
      email:    this.registerEmail,
      password: this.registerPassword
    };

    this.http.post<{ message?: string }>(`${this.apiUrl}/register`, body)
      .subscribe({
        next: () => {
          this.loading        = false;
          this.successMessage = '¡Cuenta creada! Ya puedes iniciar sesión.';
          this.activeTab      = 'login';
          // Pre-fill email
          this.loginEmail = this.registerEmail;
        },
        error: (err) => {
          this.loading      = false;
          this.errorMessage = err.error?.error ?? 'Error al registrar. Intenta de nuevo.';
        }
      });
  }
}
