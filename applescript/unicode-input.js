(function () {
    function insertText(app, text) {
        var originalClipboard = app.theClipboard();
        app.setTheClipboardTo(text);
        // console.log(text);

        delay(0.2);
        var se = Application('System Events');
        se.keyCode('v', { using: 'command down' });

        // Small delay to ensure paste completes
        delay(0.2);
        // app.setTheClipboardTo(originalClipboard);
    }

    var app = Application.currentApplication();
    app.includeStandardAdditions = true;

    var userInput = app.displayDialog("Enter Unicode Code Point:", {
        defaultAnswer: "U+",
        buttons: ["OK", "Cancel"],
        defaultButton: "OK"
    });
    if (userInput.buttonReturned !== "OK") {
        return;
    }

    var codePointHex = userInput.textReturned.trim();
    if (codePointHex.startsWith("U+")) {
      codePointHex = codePointHex.substring(2);
    }

    var codePointInt = parseInt(codePointHex, 16);

    if (isNaN(codePointInt)) {
        console.error("Invalid Unicode code point!");
        return;
    }

    // Type the Unicode character using System Events
    var unicodeChar = String.fromCodePoint(codePointInt);
    insertText(app, unicodeChar);
})();
