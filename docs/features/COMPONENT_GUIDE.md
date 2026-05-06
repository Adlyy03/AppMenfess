# 🎨 Neo-Brutalism Component Guide

## Quick Reference for All UI Components

---

## 🔲 Buttons

### Primary Button (Yellow)
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.yellow,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidth,
    ),
    boxShadow: [NeoBrutalismTheme.hardShadow()],
  ),
  child: Center(
    child: Text(
      'BUTTON TEXT',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: NeoBrutalismTheme.black,
        letterSpacing: 1.0,
      ),
    ),
  ),
)
```

### Secondary Button (Blue)
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.blue,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidth,
    ),
    boxShadow: [NeoBrutalismTheme.hardShadow()],
  ),
  child: Center(
    child: Text(
      'BUTTON TEXT',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: NeoBrutalismTheme.white,
        letterSpacing: 1.0,
      ),
    ),
  ),
)
```

### Pressed Effect
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 100),
  margin: EdgeInsets.only(
    top: _pressed ? 4 : 0,
    left: _pressed ? 4 : 0,
  ),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.yellow,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidth,
    ),
    boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
  ),
  // ... child
)
```

---

## 📦 Cards

### White Card
```dart
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.white,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidth,
    ),
    boxShadow: [NeoBrutalismTheme.hardShadow()],
  ),
  child: // ... content
)
```

### Colored Card (Hot/Featured)
```dart
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.red,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidth,
    ),
    boxShadow: [NeoBrutalismTheme.hardShadow()],
  ),
  child: // ... content
)
```

---

## 📝 Input Fields

### Text Input
```dart
TextField(
  style: GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: NeoBrutalismTheme.black,
  ),
  decoration: InputDecoration(
    hintText: 'PLACEHOLDER',
    hintStyle: GoogleFonts.spaceGrotesk(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: NeoBrutalismTheme.black.withOpacity(0.4),
    ),
    filled: true,
    fillColor: NeoBrutalismTheme.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(
        color: NeoBrutalismTheme.black,
        width: NeoBrutalismTheme.borderWidth,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(
        color: NeoBrutalismTheme.blue,
        width: NeoBrutalismTheme.borderWidth,
      ),
    ),
  ),
)
```

---

## 🏷️ Badges

### Hot Badge
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.red,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: 2,
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.whatshot, size: 12, color: NeoBrutalismTheme.white),
      const SizedBox(width: 4),
      Text(
        'HOT',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.white,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
)
```

### Info Badge
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.blue,
    border: Border.all(
      color: NeoBrutalismTheme.black,
      width: NeoBrutalismTheme.borderWidthThin,
    ),
  ),
  child: Text(
    'INFO TEXT',
    style: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: NeoBrutalismTheme.white,
    ),
  ),
)
```

---

## 📊 AppBar

### Standard AppBar
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: NeoBrutalismTheme.yellow,
    border: Border(
      bottom: BorderSide(
        color: NeoBrutalismTheme.black,
        width: NeoBrutalismTheme.borderWidth,
      ),
    ),
  ),
  child: Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.black,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
        child: const Icon(
          Icons.bolt,
          size: 24,
          color: NeoBrutalismTheme.yellow,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        'TITLE',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.black,
          letterSpacing: 1.0,
        ),
      ),
    ],
  ),
)
```

---

## 🔘 Icon Buttons

### Icon Button with Pressed Effect
```dart
GestureDetector(
  onTapDown: (_) => setState(() => _pressed = true),
  onTapUp: (_) {
    setState(() => _pressed = false);
    onTap();
  },
  onTapCancel: () => setState(() => _pressed = false),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 100),
    width: 44,
    height: 44,
    margin: EdgeInsets.only(
      top: _pressed ? 3 : 0,
      left: _pressed ? 3 : 0,
    ),
    decoration: BoxDecoration(
      color: NeoBrutalismTheme.white,
      border: Border.all(
        color: NeoBrutalismTheme.black,
        width: NeoBrutalismTheme.borderWidthThin,
      ),
      boxShadow: _pressed
          ? []
          : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
    ),
    child: const Icon(
      Icons.search,
      size: 22,
      color: NeoBrutalismTheme.black,
    ),
  ),
)
```

---

## 📋 Dividers

### Thick Divider
```dart
Container(
  height: 3,
  color: NeoBrutalismTheme.black,
)
```

### Divider with Margin
```dart
Container(
  height: 3,
  margin: const EdgeInsets.symmetric(horizontal: 16),
  color: NeoBrutalismTheme.black,
)
```

---

## 🎨 Typography Styles

### Heading 1
```dart
Text(
  'HEADING TEXT',
  style: GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: NeoBrutalismTheme.black,
    letterSpacing: -0.5,
    height: 1.1,
  ),
)
```

### Heading 2
```dart
Text(
  'HEADING TEXT',
  style: GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: NeoBrutalismTheme.black,
    letterSpacing: -0.3,
    height: 1.2,
  ),
)
```

### Body Text
```dart
Text(
  'Body text content',
  style: GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: NeoBrutalismTheme.black,
    height: 1.6,
  ),
)
```

### Label (Uppercase)
```dart
Text(
  'LABEL TEXT',
  style: GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: NeoBrutalismTheme.black,
    letterSpacing: 1.0,
  ),
)
```

---

## 🎯 Shadows

### Standard Hard Shadow
```dart
boxShadow: [
  NeoBrutalismTheme.hardShadow(),
]
// Creates: 4px offset, 0 blur, black color
```

### Custom Shadow
```dart
boxShadow: [
  NeoBrutalismTheme.hardShadow(
    offsetX: 6.0,
    offsetY: 6.0,
  ),
]
```

### No Shadow (Pressed State)
```dart
boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
```

---

## 🎨 Color Usage Guide

### Primary Actions
- **Yellow**: Main buttons, highlights, primary actions
- **Blue**: Secondary actions, selected states, info
- **Red**: Errors, hot badges, destructive actions
- **Black**: Text, borders, icons
- **White**: Backgrounds, text on colored backgrounds

### Examples
```dart
// Primary button
color: NeoBrutalismTheme.yellow,

// Secondary button
color: NeoBrutalismTheme.blue,

// Error/Hot
color: NeoBrutalismTheme.red,

// Text
color: NeoBrutalismTheme.black,

// Background
color: NeoBrutalismTheme.white,
```

---

## 🔧 Common Patterns

### Pressed Effect Pattern
```dart
class _MyButton extends StatefulWidget {
  @override
  State<_MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<_MyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        // Handle tap
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.yellow,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: // ... content
      ),
    );
  }
}
```

---

## 📐 Spacing Guide

```dart
// Small spacing
const SizedBox(height: 8)

// Medium spacing
const SizedBox(height: 16)

// Large spacing
const SizedBox(height: 24)

// Extra large spacing
const SizedBox(height: 32)

// Padding
padding: const EdgeInsets.all(16)
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
```

---

## ✨ Animation Timing

```dart
// Pressed effect
duration: const Duration(milliseconds: 100)

// State transitions
duration: const Duration(milliseconds: 200)

// Page transitions
duration: const Duration(milliseconds: 300)
```

---

## 🎊 Quick Tips

1. **Always use thick borders**: 3-4px minimum
2. **No border radius**: Keep it 0px or max 4px
3. **Hard shadows only**: 4px offset, 0 blur
4. **Bold typography**: Weight 700-900
5. **Uppercase for emphasis**: Buttons, labels, headers
6. **Pressed effect**: Remove shadow + shift position
7. **High contrast**: Use bold colors, avoid pastels
8. **Flat design**: No gradients, no blur

---

## 🚀 Ready to Use!

All components follow these patterns. Mix and match to create new UI elements that fit the Neo-Brutalism aesthetic!

**Keep it bold, keep it edgy, keep it Neo-Brutal! 💪**
