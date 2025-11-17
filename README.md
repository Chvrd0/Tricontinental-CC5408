# PORTALES - Tricontinental CC5408

This is a 2D puzzle-platformer created for the **"Taller de Videojuegos" (CC5408)** workshop.  
The project is built using the **Godot Engine (v4.4)**.

The game's core mechanic involves a **preparation phase** where the player places pairs of portals, which then become fixed. During the **play phase**, the player must navigate the level using these portals.  
The twist: portals not only teleport the player but also **change the direction of gravity** based on the exit portal's rotation.

---

## How to Run the Project

### **Prerequisites**
- Godot Engine **version 4.4 or newer**

### **Steps**
1. **Clone** the repository to your local machine.
2. **Import** the project in the Godot 4 Project Manager:  
   - Click **Import**  
   - Navigate to the cloned folder  
   - Select `portales/project.godot`
3. **Run** the project:  
   - Press **F5** to run the main menu  
   - Or open a specific level (e.g., `Levels/Playable/Level1.tscn`) and press **F6**

---

## Gameplay & Controls

Each level has **two phases**:

---

## 1. Preparation Phase

You start with a free-moving camera. Your goal is to place a limited number of portal pairs.

**Controls:**
- **Move Camera:** `W`, `A`, `S`, `D`
- **Rotate Portal (Preview):** `R`
- **Place Portal:** Left Mouse Click  
  - First click → Entry Portal  
  - Second click → Exit Portal
- **Start Game:** `Spacebar`

---

## 2. Play Phase

Once you press Spacebar, gameplay begins. The camera follows the player.

**Controls:**
- **Move Player:** `A` (Left), `D` (Right)
- **Jump:** `Spacebar`
- **Pause:** `Escape`

---

## IMPORTANT: Enabling Portal Rotation

The rotation code exists but is not bound to any key by default.  
You must add the input action manually:

1. Go to **Project > Project Settings…**
2. Click on the **Input Map** tab.
3. In *Add New Action*, type **`rotate_right`** and click **Add**.
4. Find **rotate_right** in the list and click the **+**.
5. Choose **Key**.
6. Press the **R** key (or any preferred key) and confirm.
7. Close the settings.

Portal rotation will now work during the preparation phase.

---
