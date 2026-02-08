# presence.nvim

## Installation 

## 📦 Installation

> [!NOTE]
> **presence.nvim** will automatically load with defaults; calling `setup()` is optional.

<details>
<summary><strong>lazy.nvim</strong></summary>

```lua
{
  'cjodo/presence.nvim'
}
```

> #### ⚙️ Configuring
> ```lua
> {
>   'cjodo/presence.nvim',
>    ---@type CordConfig
>   opts = {
>     -- ...
>   }
> }
> ```

</details>

<details>
<summary><strong>packer.nvim</strong></summary>

```lua
use {
  'cjodo/presence.nvim'
}
```

> #### ⚙️ Configuring
> ```lua
> use {
>   'cjodo/presence.nvim',
>   config = function()
>     require('presence').setup {
>       -- opts
>     }
>   end
> }
> ```

</details>


> #### ⚙️ Configuring
> ```lua
> require('presence').setup {
>   -- opts
> }
> ```

<details>
<summary><strong>vim.pack (v0.12+)</strong></summary>

```lua
vim.pack.add { 'https://github.com/cjodo/presence.nvim' }
```

**Configuring:**

> #### ⚙️ Configuring
> ```lua
> require('presence').setup {
>   -- opts
> }
> ```
</details>

