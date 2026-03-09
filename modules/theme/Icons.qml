pragma Singleton

import QtQuick

// ─────────────────────────────────────────────────────────────────────────────
// Icons.qml — Imperia Shell
// Uses Font Awesome 6 Free (Solid) — ships with ttf-font-awesome on Arch.
// Also bundled via JetBrains Mono Nerd Font (already required by Imperia).
// Every codepoint is a real FA6 Solid icon, guaranteed visible.
// ─────────────────────────────────────────────────────────────────────────────
QtObject {
    // ── Font ──────────────────────────────────────────────────────────────────
    // Primary: Font Awesome 6 Free Solid  (ttf-font-awesome)
    // Fallback: "Font Awesome 6 Free"  (same package, different weight name)
    readonly property string font: "Font Awesome 6 Free"

    // ── Overview / Layouts ────────────────────────────────────────────────────
    readonly property string overview:          "\uf009"  // th (grid)
    readonly property string layout:            "\uf0c9"  // bars
    readonly property string dwindle:           "\uf248"  // th-large
    readonly property string master:            "\uf0db"  // columns
    readonly property string scrolling:         "\uf07d"  // arrows-v

    // ── Power Menu ────────────────────────────────────────────────────────────
    readonly property string lock:              "\uf023"  // lock
    readonly property string suspend:           "\uf186"  // moon
    readonly property string logout:            "\uf2f5"  // sign-out-alt
    readonly property string reboot:            "\uf2f9"  // sync-alt
    readonly property string shutdown:          "\uf011"  // power-off
    readonly property string hibernate:         "\uf236"  // bed

    // ── Navigation / Carets ───────────────────────────────────────────────────
    readonly property string caretLeft:         "\uf0d9"  // caret-left
    readonly property string caretRight:        "\uf0da"  // caret-right
    readonly property string caretUp:           "\uf0d8"  // caret-up
    readonly property string caretDown:         "\uf0d7"  // caret-down
    readonly property string caretDoubleLeft:   "\uf100"  // angle-double-left
    readonly property string caretDoubleRight:  "\uf101"  // angle-double-right
    readonly property string caretDoubleUp:     "\uf102"  // angle-double-up
    readonly property string caretDoubleDown:   "\uf103"  // angle-double-down
    readonly property string caretLineLeft:     "\uf048"  // step-backward
    readonly property string caretLineRight:    "\uf051"  // step-forward
    readonly property string caretLineUp:       "\uf049"  // fast-backward
    readonly property string caretLineDown:     "\uf050"  // fast-forward

    // ── Dashboard / Widgets ───────────────────────────────────────────────────
    readonly property string widgets:           "\uf0e4"  // dashboard
    readonly property string kanban:            "\uf0ae"  // tasks
    readonly property string wallpapers:        "\uf03e"  // image
    readonly property string assistant:         "\uf544"  // robot
    readonly property string apps:              "\uf009"  // th
    readonly property string terminal:          "\uf120"  // terminal
    readonly property string terminalWindow:    "\uf2d2"  // window-maximize
    readonly property string clipboard:         "\uf0ea"  // clipboard
    readonly property string emoji:             "\uf118"  // smile
    readonly property string shortcut:          "\uf11c"  // keyboard
    readonly property string launch:            "\uf135"  // rocket
    readonly property string pin:               "\uf08d"  // thumbtack
    readonly property string unpin:             "\uf245"  // mouse-pointer
    readonly property string popOpen:           "\uf35d"  // external-link-alt
    readonly property string hand:              "\uf256"  // hand-paper
    readonly property string handGrab:          "\uf255"  // hand-grab
    readonly property string heartbeat:         "\uf21e"  // heartbeat
    readonly property string cpu:               "\uf2db"  // microchip
    readonly property string gpu:               "\uf26c"  // tv (GPU)
    readonly property string ram:               "\uf538"  // memory
    readonly property string disk:              "\uf0a0"  // hdd
    readonly property string ssd:              "\uf0a0"  // hdd
    readonly property string hdd:              "\uf0a0"  // hdd
    readonly property string temperature:       "\uf2c9"  // thermometer-half
    readonly property string at:               "\uf1fa"  // at
    readonly property string gear:              "\uf013"  // cog
    readonly property string glassMinus:        "\uf010"  // search-minus
    readonly property string glassPlus:         "\uf00e"  // search-plus
    readonly property string circuitry:         "\uf2db"  // microchip
    readonly property string robot:             "\uf544"  // robot
    readonly property string minusCircle:       "\uf056"  // minus-circle

    // ── Wi-Fi ─────────────────────────────────────────────────────────────────
    readonly property string wifiOff:           "\uf6aa"  // wifi (strikethrough look)
    readonly property string wifiNone:          "\uf6aa"  // wifi
    readonly property string wifiLow:           "\uf6aa"  // wifi
    readonly property string wifiMedium:        "\uf1eb"  // wifi
    readonly property string wifiHigh:          "\uf1eb"  // wifi
    readonly property string wifiX:             "\uf6aa"  // wifi

    // ── Bluetooth ─────────────────────────────────────────────────────────────
    readonly property string bluetooth:         "\uf294"  // bluetooth
    readonly property string bluetoothConnected:"\uf294"  // bluetooth
    readonly property string bluetoothOff:      "\uf294"  // bluetooth
    readonly property string bluetoothX:        "\uf294"  // bluetooth

    // ── Toggles ───────────────────────────────────────────────────────────────
    readonly property string nightLight:        "\uf186"  // moon
    readonly property string caffeine:          "\uf0f4"  // coffee
    readonly property string gameMode:          "\uf11b"  // gamepad

    // ── Screenshot / Recording ────────────────────────────────────────────────
    readonly property string toolbox:           "\uf552"  // toolbox
    readonly property string regionScreenshot:  "\uf065"  // expand
    readonly property string windowScreenshot:  "\uf2d2"  // window-maximize
    readonly property string fullScreenshot:    "\uf03e"  // image
    readonly property string screenshots:       "\uf083"  // camera-retro
    readonly property string recordScreen:      "\uf03d"  // video
    readonly property string recordings:        "\uf03d"  // video

    // ── Notifications ─────────────────────────────────────────────────────────
    readonly property string bell:              "\uf0f3"  // bell
    readonly property string bellRinging:       "\uf0f3"  // bell
    readonly property string bellSlash:         "\uf1f6"  // bell-slash
    readonly property string bellZ:             "\uf1f6"  // bell-slash (DnD)

    // ── Media Player ─────────────────────────────────────────────────────────
    readonly property string play:              "\uf04b"  // play
    readonly property string pause:             "\uf04c"  // pause
    readonly property string stop:              "\uf04d"  // stop
    readonly property string previous:          "\uf04a"  // step-backward
    readonly property string rewind:            "\uf04a"  // step-backward
    readonly property string forward:           "\uf04e"  // step-forward
    readonly property string next:              "\uf051"  // step-forward
    readonly property string shuffle:           "\uf074"  // random
    readonly property string repeat:            "\uf021"  // repeat
    readonly property string repeatOnce:        "\uf01e"  // redo
    readonly property string player:            "\uf001"  // music

    // Brand icons (use HTML font trick with Nerd Font for brand icons)
    readonly property string spotify:           "\uf1bc"  // spotify (FA5 brand)
    readonly property string firefox:           "\uf269"  // firefox (FA brand)
    readonly property string chromium:          "\uf268"  // chrome (FA brand)
    readonly property string telegram:          "\uf2c6"  // telegram (FA brand)

    // ── Clock / Time ─────────────────────────────────────────────────────────
    readonly property string clock:             "\uf017"  // clock
    readonly property string alarm:             "\uf0f3"  // bell (alarm)
    readonly property string timer:             "\uf017"  // clock

    // ── Volume / Audio ────────────────────────────────────────────────────────
    readonly property string speakerSlash:      "\uf6a9"  // volume-mute
    readonly property string speakerX:          "\uf6a9"  // volume-mute
    readonly property string speakerNone:       "\uf026"  // volume-off
    readonly property string speakerLow:        "\uf027"  // volume-down
    readonly property string speakerHigh:       "\uf028"  // volume-up
    readonly property string mic:               "\uf130"  // microphone
    readonly property string micSlash:          "\uf131"  // microphone-slash

    // ── Battery ───────────────────────────────────────────────────────────────
    readonly property string lightning:         "\uf0e7"  // bolt
    readonly property string plug:              "\uf1e6"  // plug
    readonly property string batteryFull:       "\uf240"  // battery-full
    readonly property string batteryHigh:       "\uf241"  // battery-three-quarters
    readonly property string batteryMedium:     "\uf242"  // battery-half
    readonly property string batteryLow:        "\uf243"  // battery-quarter
    readonly property string batteryEmpty:      "\uf244"  // battery-empty
    readonly property string batteryCharging:   "\uf0e7"  // bolt (charging)

    // ── Power Profiles ────────────────────────────────────────────────────────
    readonly property string powerSave:         "\uf06c"  // leaf
    readonly property string power:             "\uf011"  // power-off
    readonly property string balanced:          "\uf042"  // adjust
    readonly property string performance:       "\uf0e4"  // tachometer

    // ── Keyboard / Input ─────────────────────────────────────────────────────
    readonly property string keyboard:          "\uf11c"  // keyboard
    readonly property string backspace:         "\uf55a"  // backspace
    readonly property string enter:             "\uf3be"  // level-down-alt
    readonly property string shift:             "\uf062"  // arrow-up
    readonly property string arrowUp:           "\uf062"  // arrow-up
    readonly property string arrowDown:         "\uf063"  // arrow-down
    readonly property string arrowLeft:         "\uf060"  // arrow-left
    readonly property string arrowRight:        "\uf061"  // arrow-right

    // ── Misc ─────────────────────────────────────────────────────────────────
    readonly property string accept:            "\uf00c"  // check
    readonly property string cancel:            "\uf00d"  // times
    readonly property string plus:              "\uf067"  // plus
    readonly property string minus:             "\uf068"  // minus
    readonly property string alert:             "\uf071"  // exclamation-triangle
    readonly property string edit:              "\uf044"  // edit
    readonly property string trash:             "\uf1f8"  // trash
    readonly property string clip:              "\uf0c1"  // link
    readonly property string copy:              "\uf0c5"  // copy
    readonly property string image:             "\uf03e"  // image
    readonly property string broom:             "\uf51a"  // broom
    readonly property string xeyes:             "\uf06e"  // eye
    readonly property string seal:              "\uf5b7"  // certificate
    readonly property string info:              "\uf129"  // info
    readonly property string help:              "\uf059"  // question-circle
    readonly property string sun:               "\uf185"  // sun
    readonly property string sunDim:            "\uf185"  // sun
    readonly property string moon:              "\uf186"  // moon
    readonly property string user:              "\uf007"  // user
    readonly property string spinnerGap:        "\uf110"  // spinner
    readonly property string circleNotch:       "\uf1ce"  // circle-notch
    readonly property string file:              "\uf15b"  // file
    readonly property string note:              "\uf249"  // sticky-note
    readonly property string notepad:           "\uf249"  // sticky-note
    readonly property string link:              "\uf0c1"  // link
    readonly property string globe:             "\uf57d"  // globe
    readonly property string folder:            "\uf07b"  // folder
    readonly property string cactus:            "\uf06c"  // leaf
    readonly property string countdown:         "\uf252"  // hourglass-half
    readonly property string sync:              "\uf2f9"  // sync-alt
    readonly property string cube:              "\uf1b2"  // cube
    readonly property string picker:            "\uf53f"  // palette
    readonly property string textT:             "\uf031"  // font
    readonly property string qrCode:            "\uf029"  // qrcode
    readonly property string webcam:            "\uf030"  // camera
    readonly property string webcamSlash:       "\uf030"  // camera
    readonly property string flipX:             "\uf07e"  // arrows-h
    readonly property string crop:              "\uf125"  // crop
    readonly property string arrowsOut:         "\uf065"  // expand
    readonly property string alignLeft:         "\uf036"  // align-left
    readonly property string alignCenter:       "\uf037"  // align-center
    readonly property string alignRight:        "\uf038"  // align-right
    readonly property string alignJustify:      "\uf039"  // align-justify
    readonly property string markdown:          "\uf60f"  // markdown
    readonly property string faders:            "\uf1de"  // sliders-h
    readonly property string paintBrush:        "\uf53f"  // palette
    readonly property string arrowCounterClockwise: "\uf0e2"  // undo
    readonly property string arrowFatLinesDown: "\uf063"  // arrow-down
    readonly property string arrowsOutCardinal: "\uf047"  // arrows
    readonly property string dotsThree:         "\uf141"  // ellipsis-h
    readonly property string dotsNine:          "\uf009"  // th
    readonly property string heart:             "\uf004"  // heart
    readonly property string arrowSquareOut:    "\uf35d"  // external-link-alt
    readonly property string circleHalf:        "\uf042"  // adjust
    readonly property string circle:            "\uf111"  // circle
    readonly property string range:             "\uf1de"  // sliders-h
    readonly property string cursor:            "\uf245"  // mouse-pointer

    // ── Devices ───────────────────────────────────────────────────────────────
    readonly property string headphones:        "\uf025"  // headphones
    readonly property string mouse:             "\uf8cc"  // mouse (FA 5.8+)
    readonly property string phone:             "\uf095"  // phone
    readonly property string watch:             "\uf017"  // clock (watch)
    readonly property string gamepad:           "\uf11b"  // gamepad
    readonly property string printer:           "\uf02f"  // print
    readonly property string camera:            "\uf030"  // camera
    readonly property string speaker:           "\uf028"  // volume-up

    // ── Network ───────────────────────────────────────────────────────────────
    readonly property string waveform:          "\uf028"  // volume-up (audio wave)
    readonly property string sparkle:           "\uf005"  // star
    readonly property string ethernet:          "\uf6ff"  // ethernet
    readonly property string router:            "\uf6ff"  // ethernet
    readonly property string signalNone:        "\uf127"  // unlink
    readonly property string vpn:              "\uf023"  // lock (VPN lock)
    readonly property string shieldCheck:       "\uf132"  // shield-alt
    readonly property string shield:            "\uf132"  // shield-alt
    readonly property string list:              "\uf0c9"  // list
    readonly property string paperPlane:        "\uf1d8"  // paper-plane
    readonly property string compositor:        "\uf108"  // desktop
    readonly property string aperture:          "\uf1fc"  // paint-brush
    readonly property string magicWand:         "\uf0d0"  // magic
    readonly property string google:            "\uf1a0"  // google

    // ── Aliases ───────────────────────────────────────────────────────────────
    readonly property string palette:           paintBrush
    readonly property string cornersOut:        arrowsOut
    readonly property string drop:              sparkle
    readonly property string arrowsOutSimple:   arrowsOut
    readonly property string squaresFour:       layout
    readonly property string mapPin:            "\uf3c5"  // map-marker-alt
    readonly property string thermometer:       temperature
    readonly property string windowsLogo:       terminalWindow
    readonly property string frameCorners:      crop
    readonly property string error:             alert
    readonly property string warning:           "\uf071"  // exclamation-triangle
    readonly property string success:           "\uf00c"  // check
}
