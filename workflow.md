# Workflow de publicación

Este documento describe el flujo de trabajo desde una idea o problema hasta que el código termina publicado en RubyGems como beta y, finalmente, como versión estable de producción.

## 1. Idea o problema

Todo cambio empieza desde `development`.

```bash
git checkout development
git pull origin development
git checkout -b feat/nueva-funcionalidad
# o
git checkout -b fix/arreglar-error
```

Implementa el cambio, agrega o actualiza tests y documentación cuando corresponda.

Usa Conventional Commits:

```bash
git commit -m "feat: add content type detection option"
git commit -m "fix: handle empty byte input"
```

No se trabaja directo sobre `main` porque esa rama representa producción; `development` es la rama de integración.

## 2. Pull Request hacia `development`

Abre un PR desde tu branch hacia `development`:

```text
feature/fix branch → development
```

GitHub ejecuta el workflow `CI`:

- tests Ruby en 3.2, 3.3 y 3.4;
- build nativo en Linux/macOS;
- smoke test con la extensión nativa;
- build de la gema como artefacto.

Si CI falla, no se mergea. En esta etapa no se publica nada.

## 3. Preparar una beta

Para probar el mismo código como beta pública en RubyGems, primero actualiza la versión en:

```ruby
lib/magika/version.rb
```

Ejemplo:

```ruby
VERSION = "0.2.0.beta.1"
```

Ese cambio va en un PR normal hacia `development`. Después de mergear, crea el tag beta desde `development`:

```bash
git checkout development
git pull origin development
git tag v0.2.0-beta.1
git push origin v0.2.0-beta.1
```

Ese tag dispara el workflow `Release`.

## 4. Qué hace GitHub con la beta

El workflow valida:

- el tag tiene formato correcto, por ejemplo `v0.2.0-beta.1`;
- el tag corresponde a `VERSION = "0.2.0.beta.1"`;
- el commit del tag viene de `development`;
- corren los tests completos;
- se compilan gems nativas para Linux x64, Linux ARM64, macOS Intel y macOS ARM;
- se compila una source gem fallback;
- existen todos los artefactos esperados.

Si falta cualquier artefacto, no se publica nada. Si todo pasa, se publica en RubyGems como prerelease.

Instalación de beta:

```bash
gem install magika --pre
```

## 5. Validar beta en el mundo real

Probá la beta desde proyectos reales:

```ruby
gem "magika", "0.2.0.beta.1"
```

O instalando directamente:

```bash
gem install magika --pre
```

Si aparecen errores, no se toca `main`. Hace el fix desde `development`, mergea a `development` y publicá otra beta:

```ruby
VERSION = "0.2.0.beta.2"
```

```bash
git tag v0.2.0-beta.2
git push origin v0.2.0-beta.2
```

## 6. Release candidate opcional

Cuando la beta está madura, podés publicar una RC:

```ruby
VERSION = "0.2.0.rc.1"
```

Tag:

```bash
git tag v0.2.0-rc.1
git push origin v0.2.0-rc.1
```

La RC también sale desde `development` y también se publica en RubyGems como prerelease.

## 7. Promover a producción

Cuando la beta o RC está validada, abrí un PR:

```text
development → main
```

En ese PR deja la versión estable:

```ruby
VERSION = "0.2.0"
```

Cuando el PR se mergea a `main`, creá el tag estable desde `main`:

```bash
git checkout main
git pull origin main
git tag v0.2.0
git push origin v0.2.0
```

## 8. Qué hace GitHub con producción

El workflow `Release` valida:

- tag estable, por ejemplo `v0.2.0`;
- `Magika::VERSION == "0.2.0"`;
- el commit del tag viene de `main`;
- tests completos;
- build nativo completo;
- source gem fallback;
- publicación a RubyGems;
- GitHub Release estable con los `.gem`.

Instalación de producción:

```bash
gem install magika
```

## Resumen

```text
idea
  ↓
feature branch
  ↓
PR a development
  ↓
CI
  ↓
merge a development
  ↓
tag beta/rc
  ↓
RubyGems prerelease
  ↓
validación real
  ↓
PR development → main
  ↓
tag stable
  ↓
RubyGems producción + GitHub Release
```

La regla principal es: **branches gobiernan el flujo, tags publican versiones**.

- `development` no publica por push.
- `main` no publica por push.
- Solo los tags publican.
