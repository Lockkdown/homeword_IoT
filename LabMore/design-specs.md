# IOT Control Room – Light Control UI Design Specs
> ✅ Last verified: Figma MCP re-fetch lần 3 (fresh URLs)  
> Figma source: https://www.figma.com/design/YrTjRLIGX1sWAz5Jl2UehE  
> Screen size: **360 × 800px** (Android Large) | Font: **Inter Medium**

---

## 🎨 Color Tokens

| Token                  | Value                       | Usage                          |
|------------------------|-----------------------------|--------------------------------|
| `--color-bg`           | `#324539`                   | Background (luôn flat, không đổi) |
| `--color-text`         | `#ffffff`                   | Tất cả text                    |
| `--color-toggle-on`    | `#a9bdb2`                   | Toggle track khi ON            |
| `--color-toggle-off`   | `rgba(193, 193, 193, 0.5)`  | Toggle track khi OFF           |

---

## 💡 Background & Lighting — ĐỌC KỸ TRƯỚC KHI CODE

### Tại sao vùng trên đèn tối hơn vùng dưới?

Không phải dark overlay. Đến từ 2 nguồn:

1. **Lamp PNG đã baked-in shadow** ở vùng xung quanh chụp đèn — không cần code thêm bất kỳ shadow nào cho lamp.
2. **Glow ellipse chỉ đặt phía dưới** (`top: 164px`) — phần trên đèn là `#324539` thuần, phần dưới có glow → tự nhiên sáng hơn.

> ✅ Rule: Background = `#324539` flat mọi lúc. Chỉ 1 element glow (ellipse) nằm dưới bóng đèn.

---

### Glow Ellipse — So sánh 3 States (confirmed từ MCP)

#### State OFF (node `3:11`)
```
Container:
  left: 67px | top: 164px | width: 280px | height: 280px

Overflow: inset -37.14%
  → element thực tế: 280 × 1.7428 ≈ 488px (centered)

Visual: cực kỳ mờ, gần transparent
  → Hint xanh rất nhẹ, không nhận ra nếu không nhìn kỹ
```

#### State ON Low ~33% (node `6:24`)
```
Container:
  left: 67px | top: 164px | width: 280px | height: 280px

Overflow: inset -37.14% (cùng scale với OFF)

Visual: glow rõ, warm green
  → Center sáng yellowish-green, fade ra nền
```

#### State ON High ~65% (node `6:50`)
```
Container:
  left: 58px | top: 163px | width: 282px | height: 282px
  ↑ dịch sang trái 9px, lên 1px, to hơn 2px

Overflow: inset -63.83%
  → element thực tế: 282 × 2.2766 ≈ 642px (rất lớn, gần đủ màn hình)

Visual: sáng rực, center gần như trắng-vàng-xanh
  → Glow lan gần hết chiều rộng màn hình
```

#### CSS Implementation (khuyến khích thuần CSS, không dùng ảnh để animate slider mượt)
```css
.glow-ellipse {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  z-index: 1;
  transform-origin: center;
}

/* OFF */
.glow-ellipse.state-off {
  left: 67px; top: 164px;
  width: 280px; height: 280px;
  transform: scale(1.743);
  background: radial-gradient(ellipse at center,
    rgba(90, 120, 100, 0.28) 0%,
    transparent 65%
  );
}

/* ON Low (~33%) */
.glow-ellipse.state-on-low {
  left: 67px; top: 164px;
  width: 280px; height: 280px;
  transform: scale(1.743);
  background: radial-gradient(ellipse at center,
    rgba(140, 185, 155, 0.55) 0%,
    rgba(100, 145, 115, 0.25) 35%,
    transparent 65%
  );
}

/* ON High (~65%) */
.glow-ellipse.state-on-high {
  left: 58px; top: 163px;
  width: 282px; height: 282px;
  transform: scale(2.277);
  background: radial-gradient(ellipse at center,
    rgba(200, 220, 185, 0.85) 0%,
    rgba(155, 190, 155, 0.50) 25%,
    rgba(100, 145, 115, 0.22) 50%,
    transparent 70%
  );
}
```

> 💡 **Slider animation**: JS interpolate `scale` (1.743→2.277), center stop opacity (0.55→0.85), `left` (67→58), `top` (164→163) theo giá trị slider 0–100%.

---

## 📐 Layout & Component Specs (pixel-perfect)

### Container
```
width:         360px
height:        800px
background:    #324539
border-radius: 25px
box-shadow:    0px 4px 24px 10px rgba(0, 0, 0, 0.15)
overflow:      hidden
position:      relative
```

---

### z-index Stack
```
0  → background #324539
1  → glow ellipse
2  → lamp image PNG
3  → light beam vector
10 → tất cả UI elements (text, toggle, slider, icons)
```

---

### Header
```
← Arrow-left icon:
  left: 28px | top: 44px | width: 24px | height: 24px

"Kitchen" text:
  left: 58px | top: 46px
  font: Inter Medium 18px | color: #ffffff
```

---

### Lamp Image
```
left:       124px   ← = calc(20% + 52px) confirmed
top:        0px
width:      199px
height:     327px
object-fit: cover
z-index:    2

⚠️ KHÔNG thêm shadow. PNG đã có shadow baked-in.
```

---

### Light Beam (chỉ visible khi ON)
```
left:    188px   ← = calc(40% + 44px) confirmed
top:     290px
width:   70px
height:  22px
z-index: 3

Overflow (Figma inset): top -15.91%, right -5%, bottom -12.77%, left -5.08%
  → element thực: ~83px × 27px

display: none  (OFF) | block  (ON)
```

---

### Light Name Text
```
left:        35–36px
top:         503px
font:        Inter Medium 18px | color: #ffffff
line-height: normal
whitespace:  pre (giữ khoảng trắng cuối dòng 1)

Line 1: "Island Kitchen Bar "  ← có space cuối
Line 2: "LED Pendant Ceiling Light"
```

---

### Toggle Switch

```
── TRACK ──
left:          36px
top:           575px
width:         70px
height:        28px
border-radius: 23px
transition:    background 0.25s ease

OFF → background: rgba(193, 193, 193, 0.5)
ON  → background: #a9bdb2

── THUMB (circle) ──
Container size: 20×20px
Overflow (Figma inset): top 0, right -20%, bottom -40%, left -20%
  → thumb thực: 24px × 28px (overflow tạo hiệu ứng shadow/glow cho circle)

Vị trí container:
  OFF → left: 41px  | top: 579px   (thumb bên trái track)
  ON  → left: 80px  | top: 579px   (thumb bên phải track)
       ← = calc(20% + 8px) confirmed

transition: left 0.25s ease

── LABEL ──
left:      115px   ← = calc(20% + 43px) confirmed — CÙNG VỊ TRÍ cả OFF lẫn ON
top:       580px
font:      Inter Medium 16px | color: #ffffff
OFF → "OFF" | ON → "ON"
```

---

### Light Intensity Slider (chỉ visible khi ON)

```
── LABEL ──
text:  "Light Intensity"
left:  36px | top: 651px
font:  Inter Medium 16px | color: #ffffff

── TRACK LINE ──
left:   65px | top: 699px | width: 222px
height: 0 (Figma line, ~1–2px stroke)
overflow inset: top -1px, right -0.45%, bottom -1px, left -0.45%
color:  white (semi-transparent ~0.4)

── ICONS ──
Min bulb (dim):    left: 28px  | top: 682px | size: 34×34px | rotate: 180deg
Max bulb (bright): left: calc(80%+4px)=292px | top: 682px | size: 34×34px | rotate: 180deg

── THUMB INDICATOR (dot + filled line) ──
Container (Frame 1/2):
  left:   65px
  top:    694px
  height: 11px

  ON Low  → width: 122px  (slider ~33%)
  ON High → width: 188px  (slider ~65%)

Filled line:  overflow left -1.06%~-1.64%
Dot (Ellipse 3): size 11×11px | right edge của container | color: #ffffff
```

---

## 🔄 State Transition Logic

```
INITIAL → OFF
  Background:    #324539 flat
  Glow ellipse:  state-off (mờ, scale 1.743)
  Lamp PNG:      tối (no light beam)
  Light beam:    display: none
  Toggle track:  rgba(193,193,193,0.5)
  Toggle thumb:  left: 41px
  Toggle label:  "OFF"
  Slider:        display: none

── USER TAPS TOGGLE ──

→ ON state:
  Glow ellipse:  state-on-low
  Light beam:    display: block (fade in)
  Toggle track:  #a9bdb2 (transition 0.25s)
  Toggle thumb:  left: 80px (transition 0.25s)
  Toggle label:  "ON"
  Slider:        display: block, default ~33%

── USER DRAGS SLIDER ──

  0%   → glow = state-on-low  (scale 1.743, center rgba 0.55)
  100% → glow = state-on-high (scale 2.277, center rgba 0.85)
  Interpolate: scale, opacity, left (67→58), top (164→163)
  Slider thumb width: 122px → 222px (65→287px absolute range)

── USER TAPS TOGGLE AGAIN ──

→ OFF state: ngược lại toàn bộ
```

---

## 🗂️ Fresh Asset URLs (re-fetched — valid 7 ngày từ hôm nay)

### Frame 1 – OFF state
| Asset               | URL |
|---------------------|-----|
| Arrow Left Icon     | `https://www.figma.com/api/mcp/asset/a6878303-34f8-4b30-8afc-10ac6a0e82c5` |
| Lamp PNG            | `https://www.figma.com/api/mcp/asset/b7ff6b53-d9c2-4f2d-8c1a-05c9bbc10750` |
| Glow Ellipse img    | `https://www.figma.com/api/mcp/asset/4e167a94-33ff-4ca0-b0f4-f25939d386f9` |
| Toggle Thumb img    | `https://www.figma.com/api/mcp/asset/016d09a1-c5b0-4d63-96a5-25d145a61f06` |

### Frame 2 – ON Low (~33%)
| Asset               | URL |
|---------------------|-----|
| Arrow Left Icon     | `https://www.figma.com/api/mcp/asset/215bcc60-7903-4249-b814-ad39c7906de2` |
| Lamp PNG            | `https://www.figma.com/api/mcp/asset/c27ae5e4-d814-4882-a087-8ba12e73e438` |
| Glow Ellipse img    | `https://www.figma.com/api/mcp/asset/1e84c47d-ee7d-4291-b2bc-6d9f67c060c9` |
| Light Beam Vector   | `https://www.figma.com/api/mcp/asset/a0969d4b-50df-4963-b6f2-02669e94200d` |
| Toggle Thumb img    | `https://www.figma.com/api/mcp/asset/74939f4f-0757-4822-945b-792299205344` |
| Bulb Icon Min       | `https://www.figma.com/api/mcp/asset/ea117352-e580-480d-a7cb-6b01fba08ea8` |
| Bulb Icon Max       | `https://www.figma.com/api/mcp/asset/daf31177-87dc-40b6-81b2-d0850b9724f1` |
| Slider Track Line   | `https://www.figma.com/api/mcp/asset/0950fb38-cff4-435b-89b9-62fc1a6d413d` |
| Slider Thumb (~33%) | `https://www.figma.com/api/mcp/asset/791bc070-de5c-44e5-ae0f-d39f7829ce86` |

### Frame 3 – ON High (~65%)
| Asset               | URL |
|---------------------|-----|
| Arrow Left Icon     | `https://www.figma.com/api/mcp/asset/873e788d-8588-47b7-9678-24d668f73b83` |
| Lamp PNG            | `https://www.figma.com/api/mcp/asset/6473b832-c6f6-4928-8671-fd7e9437a45b` |
| Glow Ellipse img    | `https://www.figma.com/api/mcp/asset/8db2f0c5-7d33-42f4-b088-95530796d59b` |
| Light Beam Vector   | `https://www.figma.com/api/mcp/asset/5b52d91b-3da7-4785-9bda-d704ef247633` |
| Toggle Thumb img    | `https://www.figma.com/api/mcp/asset/02cc4758-2510-4417-a000-fcf243e8bea0` |
| Bulb Icon Min       | `https://www.figma.com/api/mcp/asset/84ac2265-bd48-4884-a087-c3c79aff1fe8` |
| Bulb Icon Max       | `https://www.figma.com/api/mcp/asset/910166a9-02a2-4075-bdb7-285c2701974d` |
| Slider Track Line   | `https://www.figma.com/api/mcp/asset/87597ad5-be03-435e-9a98-4a0b46f0dd93` |
| Slider Thumb (~65%) | `https://www.figma.com/api/mcp/asset/dd1cdc6f-5760-4c39-902b-39b64f616326` |

> ⚠️ URLs expire sau **7 ngày**. Re-fetch qua Figma MCP nếu cần.

---

## ⚠️ Windsurf Implementation Checklist

- [ ] Background luôn `#324539` — không thêm overlay hay gradient nào lên background
- [ ] Lamp PNG tự có shadow — KHÔNG code thêm `box-shadow` hay dark vignette
- [ ] Glow ellipse dùng `transform: scale()` để overflow, container dùng `overflow: hidden` để clip
- [ ] Toggle label `left: 115px` cố định — chỉ thay đổi **content** (OFF/ON), không dịch vị trí
- [ ] Toggle thumb `left: 41px` (OFF) → `left: 80px` (ON) với `transition: 0.25s ease`
- [ ] Toggle thumb overflow `inset [0 -20% -40% -20%]` tạo hiệu ứng shadow/glow cho circle
- [ ] Slider thumb width = 122px (~33%) → 188px (~65%), không phải vị trí `left`
- [ ] Bulb icons có `rotate: 180deg`
- [ ] Implement glow = **CSS radial-gradient thuần** để slider animation mượt