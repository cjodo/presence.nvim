# presence.nvim
💓 Pulse.nvim is an open-source Neovim plugin that broadcasts your editor activity to the web in real-time — Inspired by [cord.nvim](https://github.com/vyfor/cord.nvim/).

Liven up your portfolio by adding a simple api to display your nvim status!! 

[Live Demo](https://cjodo.com#about) 

If you missed me heres a photo to demo!

<img width="507" height="353" alt="presence" src="https://github.com/user-attachments/assets/17cc4bf8-597c-48ad-b21b-8d808c73085f" />

## 📦 Installation

> [!NOTE]
> **presence.nvim** will automatically load with defaults; calling `setup()` is optional.

### Lazy

```lua
{
  'cjodo/presence.nvim'
}

```
#### ⚙️ Configuring
```lua
{
  'cjodo/presence.nvim',
  opts = {
    endpoints = {
        "http://localhost:8080/api/your-endpoint",
        "http://localhost:3000/presence" --for the dev example server
      },
   }
 }
 ```

#### Development
For a look at the state being sent to your endpoints make sure to include localhost:3000/presence in your config.  
- go to the dev server
```bash
cd server
npm install 
node index.js
```
you can visit your browser http://localhost:3000/presence to see whats happening
