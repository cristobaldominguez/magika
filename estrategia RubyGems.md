Ya tengo una pista clara: RubyGems soporta prereleases de forma nativa y hoy la forma más limpia de publicar es mediante _trusted publishing_ con GitHub Actions, sin guardar API keys en secrets. Ahora voy a aterrizar eso a un flujo beta desde `development` y estable desde `main` .

Sí, se puede hacer, pero te recomendaría **no pensar la publicación “desde ramas” como mecanismo principal** , sino como **publicación por tags/versiones**, usando las ramas solo como fuente de verdad del código.

La razón es que RubyGems ya soporta **prereleases** de forma nativa: una versión pasa a ser prerelease simplemente si contiene letras, por ejemplo `1.4.0.beta.1` , `1.4.0.rc1` o `1.4.0.pre` . Además, esas versiones no se instalan por defecto; el consumidor tiene que pedirlas explícitamente con `--pre` o indicar la versión concreta. [guides.rubygems.org +2 guides.rubygems.org +2](https://guides.rubygems.org/patterns/)

## Lo que te recomiendo

### Estrategia recomendada

Usa **un solo gem name** en RubyGems y dos tipos de release:

*   `main` → releases estables  
    Ej.: `1.4.0` , `1.4.1`
    
*   `development` → prereleases  
    Ej.: `1.5.0.beta.1` , `1.5.0.beta.2` , `1.5.0.rc1`
    

Eso encaja muy bien con cómo RubyGems trata prereleases. No necesitas otro paquete ni otro registro solo por tener beta. [guides.rubygems.org +1](https://guides.rubygems.org/patterns/)

## Por qué esta opción es mejor que “publicar automáticamente por rama”
Porque en gems conviene que **cada publicación sea intencional** . RubyGems te deja publicar nuevas versiones y yankear versiones existentes, pero la publicación es un acto de release, no algo que normalmente quieras disparar en cada push. [guides.rubygems.org +1](https://guides.rubygems.org/rubygems-org-api/?utm_source=chatgpt.com)

En la práctica, el flujo más sano suele ser:

*   haces cambios en `development`
*   cuando quieres sacar una beta, creas un **tag**
*   cuando quieres sacar estable, mergeas a `main` y creas otro **tag**

## Flujo concreto que te propongo

**Tags semánticos + dos workflows**

*   En `development` :
    *   tag: `v1.5.0-beta.1`
    *   la gemspec/version.rb contiene `1.5.0.beta.1`
    *   workflow de beta publica esa versión
*   En `main` :
    *   tag: `v1.5.0`
    *   la gemspec/version.rb contiene `1.5.0`
    *   workflow de release publica estable

## Automatización actual recomendada

Hoy la forma más limpia de publicar en RubyGems desde GitHub es **Trusted Publishing** con GitHub Actions. RubyGems documenta que puedes usar su action `rubygems/release-gem` con OIDC, sin guardar usuario, password ni API key fija en secrets. También permite registrar un mismo repo/workflow para uno o varios gems, y un gem puede aceptar múltiples publishers/workflows. [guides.rubygems.org](https://guides.rubygems.org/trusted-publishing/)

GitHub además permite proteger ramas con status checks y reviews, y los environments pueden exigir aprobación manual o restringirse a ciertas ramas antes de que el job continúe. [GitHub Docs +1](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

## Cómo lo montaría yo

### Branches
*   `main` protegida
*   `development` protegida

### Reglas
*   ambas con CI obligatoria
*   `main` con reviews obligatorias
*   opcionalmente un environment `release` con aprobación manual para la estable
*   opcionalmente un environment `beta` más flexible para prereleases [GitHub Docs +1](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

### Versionado

En `lib/tu_gem/version.rb` :

```ruby
module TuGem
  VERSION = "1.5.0.beta.1"
end
```

y luego para estable:

```ruby
module TuGem
  VERSION = "1.5.0"
end
```
RubyGems considera prerelease cualquier versión que tenga letras. [guides.rubygems.org +1](https://guides.rubygems.org/specification-reference/)

## Alternativas reales

### 1\. Un solo gem con prereleases
La mejor para open source o librerías normales.

**Pros**
*   estándar RubyGems
*   simple para usuarios
*   sin duplicar nombre de paquete

**Contras**
*   los testers tienen que instalar con `--pre` o fijar la beta

### 2\. GitHub Packages o registro privado para betas internas
Si no quieres que las betas estén visibles en RubyGems públicas, puedes mandar las prereleases a un registry privado y dejar RubyGems solo para estable.

**Pros**
*   las betas no quedan públicas
*   útil si es una gem interna

**Contras**
*   añade fricción a instalación y auth

### 3\. Nightly/edge builds
Publicar snapshots frecuentes tipo `1.5.0.dev.20260423` .
Yo no lo haría salvo que tengas muchos testers. En gems suele generar ruido.

## Mi recomendación final

Yo montaría esto así:
1.  **`development` para integración**
2.  **`main` para estable**
3.  **prereleases con versiones `beta` o `rc`**
4.  **publicación por tag**, no por push a rama
5.  **Trusted Publishing con GitHub Actions**
6.  **branch protection + environment approval** para la release estable

Quedaría algo así:
*   `development` → tag `v1.6.0-beta.1` → publica `1.6.0.beta.1`
*   `development` → tag `v1.6.0-rc.1` → publica `1.6.0.rc.1`
*   merge a `main`
*   `main` → tag `v1.6.0` → publica `1.6.0`

Es simple, estándar y muy mantenible. [GitHub Docs +3 guides.rubygems.org +3 guides.rubygems.org +3](https://guides.rubygems.org/patterns/)

## Lo único que evitaría

Evitaría esto:
*   publicar automáticamente en cada push a `development`, te puede llenar RubyGems de versiones poco útiles

## Mi veredicto

Tu idea de:
*   beta desde `development`
*   estable desde `main`

**es buena**, pero la implementaría como:
*   **branches para gobernanza**
*   **versions + tags para publicar**
