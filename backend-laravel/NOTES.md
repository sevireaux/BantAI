# How these files fit into a real Laravel project

This folder is **not** a complete, runnable Laravel installation — Laravel's
framework core (bootstrap/, public/index.php, vendor/, the `artisan` CLI,
and most of config/) must come from Composer, which requires network access
this environment doesn't have.

Instead, this folder contains the **custom application code** for BantAI:
migrations, models, controllers, services, policies, routes, seeders, and
Livewire admin-panel components. The root README's "Backend setup" section
walks through scaffolding a fresh Laravel project with Composer and then
copying these files in — see that section before touching anything here.

`composer.reference.json` lists the exact packages/versions this code
expects — use it as a reference for `composer require`, don't copy it over
your generated `composer.json`.
