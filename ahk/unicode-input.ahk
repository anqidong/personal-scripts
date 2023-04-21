#Requires AutoHotkey v2.0
#SingleInstance

^+u:: {
    ib_out := InputBox("Enter U+", "Unicode input", "W240 H100", "U+")

    if (ib_out.result != "OK") {
        return
    }

    num_str := ib_out.value

    if (InStr(num_str, "U+") = 1) {
        num_str := SubStr(num_str, 3)
    }

    if (SubStr(num_str, 1, 5) = "shrug") {
        SendInput "¯\_(ツ)_/¯"
    } else {
        num_str := "0x" num_str
        key_out := Chr(Integer(num_str))

        Send "{Raw}" key_out
    }
}
