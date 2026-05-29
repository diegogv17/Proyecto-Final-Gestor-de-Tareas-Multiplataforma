import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',        // ← debe coincidir con <app-root> del index.html
  standalone: true,
  imports: [RouterOutlet],
  template: `<router-outlet />`  // ← renderiza la ruta activa (/login)
})
export class AppComponent {}