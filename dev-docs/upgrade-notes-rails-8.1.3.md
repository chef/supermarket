# Upgrade Notes: Ruby 3.1.2 → 3.3.x and Rails 7.1.5.2 → 8.1.3

This document describes every breaking change relevant to the Supermarket codebase when
upgrading to Ruby 3.3.x and Rails 8.1.3, with exact file paths and line numbers.

**Recommended upgrade order** (Rails docs say to upgrade Ruby and Rails separately):
1. Ruby 3.1.2 → 3.3.x first (Rails 8.0+ requires Ruby ≥ 3.2.0; do Ruby before Rails)
2. Rails 7.1 → 7.2 (intermediate step — do not skip)
3. Rails 7.2 → 8.0
4. Rails 8.0 → 8.1.3

Run the full test suite after each step before moving to the next.

---

## Part 1: Ruby 3.1.2 → 3.3.x

### 🔴 Breaking: `lambda(&proc_instance)` now raises `ArgumentError` (Ruby 3.3)

Passing a `Proc` object to `lambda()` via `&` now raises instead of silently returning
the proc unchanged.

```ruby
p = proc { |a| a }

# Ruby ≤ 3.2: returned p unchanged (not actually a lambda)
l = lambda(&p)

# Ruby 3.3:
l = lambda(&p)  # ArgumentError: the lambda method requires a literal block
```

**Supermarket impact:** Searched codebase — no instances found. ✅ Safe.

---

### 🔴 Breaking: Anonymous parameter forwarding inside blocks raises `SyntaxError` (Ruby 3.3)

A block that declares `|*|` can no longer forward `*` if the enclosing method also has
anonymous params, as the semantics were ambiguous and broken.

```ruby
def m(*)
  [1,2,3].each { |*| p(*) }  # Ruby 3.3: SyntaxError
end
```

**Supermarket impact:** Not found in codebase. ✅ Safe.

---

### 🟡 Warning: `it` as a bare identifier inside blocks (Ruby 3.3 warns; Ruby 3.4 breaks)

In Ruby 3.3, using `it` as a method call or local variable inside a block without
explicit parameters produces a warning. In Ruby 3.4 it becomes the anonymous block
argument (`_1` equivalent).

This does **not** affect RSpec's `it` blocks (they have descriptions/blocks attached).
Watch for any helper methods or local variables literally named `it` used bare inside
a block.

**Supermarket impact:** Unlikely, but run the test suite and check for
`warning: 'it' calls without arguments will refer to the first block param` messages.

---

### 🟡 Behaviour change: Constant assignment evaluation order (Ruby 3.2)

For `ModuleExpr::CONST = value_expr`, Ruby now evaluates `ModuleExpr` first, then
`value_expr`. Previously `value_expr` was evaluated first.

```ruby
# Ruby 3.1: runs expensive_call(), then raises NameError
# Ruby 3.2: raises NameError immediately; expensive_call() never runs
NonExistentModule::CONST = expensive_call()
```

**Supermarket impact:** No direct instances in app code. Relevant if autoloaders or
initializers assign constants on non-guaranteed module paths. Low risk.

---

## Part 2: Rails 7.1.5.2 → 7.2.x

### 🔴 Must Fix: Bump `config.load_defaults`

**File:** `src/supermarket/config/application.rb`, line 31

```ruby
# Before
config.load_defaults 7.1

# After
config.load_defaults 7.2
```

After changing this, run `bin/rails app:update` to generate
`config/initializers/new_framework_defaults_7_2.rb`. Review and enable each opt-in
individually before moving on.

---

### 🔴 Must Verify: ActiveJob inside transactions is now deferred (Rails 7.2)

In Rails 7.2, jobs enqueued inside an `ActiveRecord` transaction block are automatically
held until after the transaction commits, instead of being enqueued immediately.

**Files containing `transaction do`:**

| File | Line |
|---|---|
| `src/supermarket/app/models/cookbook.rb` | 276 |
| `src/supermarket/app/models/collaborator.rb` | 31 |
| `src/supermarket/app/models/user.rb` | 202 |

None of the transaction blocks currently call `perform_later` directly — the
transactions only do DB saves. This is safe as-is, but if a job is ever added inside
these blocks in the future the deferral will apply automatically.

**Action:** No code change needed now. Add a comment to each transaction block noting
the Rails 7.2 deferral behaviour so future developers are aware:

```ruby
# NOTE: Rails 7.2+ defers any perform_later calls inside a transaction until commit.
transaction do
  ...
end
```

---

### 🟡 Behaviour change: `alias_attribute` bypasses custom accessors (Rails 7.2)

`alias_attribute` now directly aliases the raw DB column, bypassing any custom reader
method defined on the original attribute.

**Supermarket impact:** Searched all models — no `alias_attribute` usage found. ✅ Safe.

---

### 🟡 Test: ActiveJob `queue_adapter` now consistently applied (Rails 7.2)

If `config.active_job.queue_adapter` is set in `config/environments/test.rb`, all tests
now use it. Previously some tests silently fell back to `:test`.

**File:** `src/supermarket/config/environments/test.rb`

No `queue_adapter` is currently set in the test environment — the default `:test`
adapter continues to apply. ✅ Safe.

---

## Part 3: Rails 7.2 → 8.0

### 🔴 Must Fix: `config.cache_classes` removed (Rails 8.0)

`config.cache_classes` was deprecated in Rails 7.1 and **removed in Rails 8.0**.
It is replaced by `config.enable_reloading` (inverted logic).

**File:** `src/supermarket/config/environments/test.rb`, line 10

```ruby
# Before (raises NoMethodError in Rails 8.0)
config.cache_classes = true

# After
config.enable_reloading = false
```

**File:** `src/supermarket/config/environments/development.rb`, line 9

```ruby
# Before
config.cache_classes = false

# After
config.enable_reloading = true
```

**File:** `src/supermarket/config/environments/production.rb`, line 7

```ruby
# Before
config.cache_classes = true

# After
config.enable_reloading = false
```

---

### 🔴 Must Fix: `config.assets.js_compressor = :uglifier` removed (Rails 8.0)

The `:uglifier` compressor is no longer supported as a symbol shorthand. The `uglifier`
gem itself also requires Node.js and is incompatible with ExecJS-less environments.

**Files:**
- `src/supermarket/config/environments/production.rb`, line 28
- `src/supermarket/engines/fieri/spec/dummy/config/environments/production.rb`

```ruby
# Before
config.assets.js_compressor = :uglifier

# After — option 1: remove compression (assets are already minified by build tools)
# config.assets.js_compressor = :uglifier   # remove this line

# After — option 2: switch to terser (if JS minification is still needed)
# Gemfile: gem 'terser'
config.assets.js_compressor = :terser
```

For Supermarket's production deployment the asset pipeline is typically handled by
nginx serving precompiled assets, so simply removing the line is the recommended path.

---

### 🟡 Config: `config.load_defaults` bump for 8.0

After completing the 7.2 step, bump again:

**File:** `src/supermarket/config/application.rb`, line 31

```ruby
config.load_defaults 8.0
```

Run `bin/rails app:update` and review `config/initializers/new_framework_defaults_8_0.rb`.

---

## Part 4: Rails 8.0 → 8.1.3

### 🔴 Must Fix: Semicolons no longer work as query string separators (Rails 8.1)

The `ActionDispatch` parameter parser no longer splits on `;` in query strings.

```ruby
# Before Rails 8.1
"foo=bar;baz=quux"  # parsed as { "foo" => "bar", "baz" => "quux" }

# Rails 8.1
"foo=bar;baz=quux"  # parsed as { "foo" => "bar;baz=quux" }
```

**Supermarket impact:** Any API client or internal code sending semicolon-delimited
query strings will break silently. Audit the API and health check endpoints.
`src/supermarket/app/lib/supermarket/health.rb` uses raw SQL queries, not query strings,
so that file is safe. Verify no client-facing URL generation uses semicolons.

---

### 🔴 Must Fix: Leading brackets in parameter names no longer stripped (Rails 8.1)

```ruby
# Before Rails 8.1
"[foo]=bar"       # parsed as { "foo" => "bar" }
"[foo][bar]=baz"  # parsed as { "foo" => { "bar" => "baz" } }

# Rails 8.1
"[foo]=bar"       # parsed as { "[foo]" => "bar" }
```

**Supermarket impact:** The API receives cookbook upload parameters and version queries.
Check all API request parameter keys — none currently documented as bracket-prefixed,
but verify against any external cookbook upload clients.

---

### 🟡 Config: `config.load_defaults` final bump

**File:** `src/supermarket/config/application.rb`, line 31

```ruby
config.load_defaults 8.1
```

Run `bin/rails app:update` and review `config/initializers/new_framework_defaults_8_1.rb`.

Notable 8.1 default: `schema.rb` table columns are now sorted alphabetically. This
will produce a large diff on next `db:schema:dump` but is purely cosmetic — no logic
changes required.

---

## Summary Checklist

### Ruby 3.3 (do first)
- [ ] Run test suite and check for `warning: 'it' calls` in output
- [ ] Verify no `lambda(&proc_variable)` patterns in app code (none found)

### Rails 7.2
- [ ] `config/application.rb` line 31: `config.load_defaults 7.1` → `7.2`
- [ ] Run `bin/rails app:update`, review `new_framework_defaults_7_2.rb`
- [ ] Review `transaction do` blocks in `cookbook.rb:276`, `collaborator.rb:31`, `user.rb:202` — no jobs inside, but add explanatory comments
- [ ] Run full test suite: `RAILS_ENV=test bundle exec rake spec`

### Rails 8.0
- [ ] `config/environments/test.rb` line 10: `cache_classes = true` → `enable_reloading = false`
- [ ] `config/environments/development.rb` line 9: `cache_classes = false` → `enable_reloading = true`
- [ ] `config/environments/production.rb` line 7: `cache_classes = true` → `enable_reloading = false`
- [ ] `config/environments/production.rb` line 28: remove `config.assets.js_compressor = :uglifier`
- [ ] `engines/fieri/spec/dummy/config/environments/production.rb`: same `js_compressor` removal
- [ ] `config/application.rb`: `config.load_defaults 8.0`
- [ ] Run `bin/rails app:update`, review `new_framework_defaults_8_0.rb`
- [ ] Run full test suite

### Rails 8.1.3
- [ ] Audit API endpoints for semicolon-delimited query string usage
- [ ] Audit API parameter names for leading `[` bracket patterns
- [ ] `config/application.rb`: `config.load_defaults 8.1`
- [ ] Run `bin/rails app:update`, review `new_framework_defaults_8_1.rb`
- [ ] Run `db:schema:dump` — expect large alphabetical column sort diff (cosmetic only)
- [ ] Run full test suite: `RAILS_ENV=test bundle exec rake spec`

---

## References

- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 7.2 Release Notes](https://guides.rubyonrails.org/7_2_release_notes.html)
- [Rails 8.0 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html)
- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [Ruby 3.2 Changes](https://rubyreferences.github.io/rubychanges/3.2.html)
- [Ruby 3.3 Changes](https://rubyreferences.github.io/rubychanges/3.3.html)
