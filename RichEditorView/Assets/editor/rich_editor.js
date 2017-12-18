/**
 * Copyright (C) 2015 Wasabeef
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
"use strict";

var RE = {};

window.onload = function() {
    RE.callback("ready");
};

RE.editor = document.getElementById('editor');

/* List of options currently in RichEditorToolbar listed in the format of "javascript command identifier" : "option name listed in RichEditorOptionItem" */
RE.toolbarOptions = {
    "undo": "Undo",
    "redo": "Redo",
    "bold": "Bold",
    "italic": "Italic",
    "subscript": "Sub",
    "superscript": "Super",
    "strikeThrough": "Strike",
    "underline": "Underline",
    "foreColor": "Color",
    "hiliteColor": "BG Color",
    "header1": "H1",
    "header2": "H2",
    "header3": "H3",
    "header4": "H4",
    "header5": "H5",
    "header6": "H6",
    "indent": "Indent",
    "outdent": "Outdent",
    "insertOrderedList": "Ordered List",
    "insertUnorderedList": "Unordered List",
    "justifyLeft": "Left",
    "justifyCenter": "Center",
    "justifyRight": "Right"
}

/* Index of header number from RE.toolbarOptions (e.g. "header1", 1 is index number 6) */
RE.headerNumberIndex = 6;

// Not universally supported, but seems to work in iOS 7 and 8
document.addEventListener("selectionchange", function() {
                          RE.getCurrentStyle();
                          RE.backuprange();
                          });

window.addEventListener("keydown", function(key) {
                          RE.getCurrentStyle();
                          RE.backuprange();

                        /* Ensure <p> tags are used on line breaks
                         (except when selected text contains a list) */
                        if(key.keyCode == '13' &&
                             !document.queryCommandState("insertOrderedList") &&
                             !document.queryCommandState("insertUnorderedList")) {
                        
                            /* When p tags not used yet, format current block with p
                             tags, so that each line break will use p tags later on */
                            if(document.queryCommandValue("formatBlock") != 'p') {
                                document.execCommand('formatBlock', false, 'p');
                                key.preventDefault();
                                RE.insertHTML("<br>");
                            }
                        } 
});

//looks specifically for a Range selection and not a Caret selection
RE.rangeSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && sel.type == "Range") {
        return true;
    }
    return false;
};

RE.rangeOrCaretSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && (sel.type == "Range" || sel.type == "Caret")) {
        return true;
    }
    return false;
};

RE.editor.addEventListener("input", function(e) {
                           //RE.updatePlaceholder();
                           RE.backuprange();
                           });

RE.editor.addEventListener("focus", function() {
                           RE.editor.classList.remove("placeholder");
                           RE.backuprange();
                           RE.callback("focus");
                           });

RE.editor.addEventListener("blur", function() {
                           RE.updatePlaceholder();
                           RE.callback("blur");
                           });

RE.customAction = function(action) {
    RE.callback("action/" + action);
};

RE.updateHeight = function() {
    RE.callback("updateHeight");
}

RE.callbackQueue = [];
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;
    }
    
    setTimeout(function() {
               window.location.href = "re-callback://";
               }, 0);
};

RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

RE.callback = function(method) {
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

RE.setHtml = function(contents) {
    var tempWrapper = document.createElement("p");
    tempWrapper.innerHTML = contents;
    var images = tempWrapper.querySelectorAll("img");
    
    for (var i = 0; i < images.length; i++) {
        images[i].onload = RE.updateHeight;
    }
    
    RE.editor.innerHTML = tempWrapper.innerHTML;
    //RE.updatePlaceholder();
};

/* Find out current applied styles and passes them to the rich editor view to update the toolbar */
RE.getCurrentStyle = function() {
    var appliedStyles = "";
    for(var command in RE.toolbarOptions) {
        if(document.queryCommandState(command)) {
            appliedStyles += RE.toolbarOptions[command] + ","
        }
        
        if(command.includes("header")) {
            var formatBlock = document.queryCommandValue('formatBlock');
            if(formatBlock.length > 1 && formatBlock[1] == command[6]) {
                appliedStyles += RE.toolbarOptions[command] + ",";
            }
        }
    }
    RE.customAction(appliedStyles);
};

RE.getHtml = function() {
    return RE.editor.innerHTML;
};

RE.getOuterHtml = function() {
    return RE.editor.outerHTML;
};

RE.getText = function() {
    return RE.editor.innerText;
};

RE.setPlaceholderText = function(text) {
    RE.editor.setAttribute("placeholder", text);
};

RE.updatePlaceholder = function() {
    if (RE.editor.innerHTML.indexOf('img') !== -1 || (RE.editor.textContent.length > 0 && RE.editor.innerHTML.length > 0)) {
        RE.editor.classList.remove("placeholder");
    } else {
        RE.editor.classList.add("placeholder");
    }
};

RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
    document.execCommand('unlink', false, null);
};

RE.setFontSize = function(size) {
    RE.editor.style.fontSize = size;
};

RE.setBackgroundColor = function(color) {
    RE.editor.style.backgroundColor = color;
};

RE.setHeight = function(size) {
    RE.editor.style.height = size;
};

RE.undo = function() {
    document.execCommand('undo', false, null);
};

RE.redo = function() {
    document.execCommand('redo', false, null);
};

RE.setBold = function() {
    document.execCommand('bold', false, null);
};

RE.setItalic = function() {
    document.execCommand('italic', false, null);
};

RE.setSubscript = function() {
    document.execCommand('subscript', false, null);
};

RE.setSuperscript = function() {
    document.execCommand('superscript', false, null);
};

RE.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
};

RE.setUnderline = function() {
    document.execCommand('underline', false, null);
};

RE.setTextColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.setTextBackgroundColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.setHeading = function(heading) {
    document.execCommand('formatBlock', false, '<h' + heading + '>');
};

RE.setIndent = function() {
    document.execCommand('indent', false, null);
};

RE.setOutdent = function() {
    document.execCommand('outdent', false, null);
};

/* Reset block format to <p> when list is toggled off */
RE.setOrderedList = function() {
    if(document.queryCommandState("insertOrderedList")) {
        RE.restorerange();
        document.execCommand('formatBlock', false, 'p');
    }
    document.execCommand('insertOrderedList', false, null);
};

RE.setUnorderedList = function() {
    if(document.queryCommandState("insertUnorderedList")) {
        document.execCommand('formatBlock', false, 'p');
    }
    document.execCommand('insertUnorderedList', false, null);
};

RE.setJustifyLeft = function() {
    RE.getCurrentStyle();
    document.execCommand('justifyLeft', false, null);
};

RE.setJustifyCenter = function() {
    RE.getCurrentStyle();
    document.execCommand('justifyCenter', false, null);
};

RE.setJustifyRight = function() {
    RE.getCurrentStyle();
    document.execCommand('justifyRight', false, null);
};

RE.getLineHeight = function() {
    return RE.editor.style.lineHeight;
};

RE.setLineHeight = function(height) {
    RE.editor.style.lineHeight = height;
};

RE.insertImage = function(url, alt) {
    var img = document.createElement('img');
    img.setAttribute("src", url);
    img.setAttribute("alt", alt);
    img.onload = RE.updateHeight;
    
    RE.insertHTML(img.outerHTML);
    RE.callback("input");
};

RE.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
};

RE.insertHTML = function(html) {
    RE.restorerange();
    document.execCommand('insertHTML', false, html);
};

RE.insertLink = function(url, title) {
    RE.restorerange();
    var sel = document.getSelection();
    if (sel.toString().length !== 0) {
        if (sel.rangeCount) {
            
            var el = document.createElement("a");
            el.setAttribute("href", url);
            // el.setAttribute("title", title);
            
            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    } else {
        document.execCommand("insertHTML", false, "<a href='" + url + "'>" + title + "</a>");
    }
    RE.callback("input");
};

RE.prepareInsert = function() {
    RE.backuprange();
};

RE.backuprange = function() {
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
        var range = selection.getRangeAt(0);
        RE.currentSelection = {
            "startContainer": range.startContainer,
            "startOffset": range.startOffset,
            "endContainer": range.endContainer,
            "endOffset": range.endOffset
        };
    }
};

RE.addRangeToSelection = function(selection, range) {
    if (selection) {
        selection.removeAllRanges();
        selection.addRange(range);
    }
};

// Programatically select a DOM element
RE.selectElementContents = function(el) {
    var range = document.createRange();
    range.selectNodeContents(el);
    var sel = window.getSelection();
    // this.createSelectionFromRange sel, range
    RE.addRangeToSelection(sel, range);
};

RE.restorerange = function() {
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
    range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
    selection.addRange(range);
};

RE.focus = function() {
    var range = document.createRange();
    range.selectNodeContents(RE.editor);
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.focusAtPoint = function(x, y) {
    var range = document.caretRangeFromPoint(x, y) || document.createRange();
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.blurFocus = function() {
    RE.editor.blur();
};

/**
 Recursively search element ancestors to find a element nodeName e.g. A
 **/
var _findNodeByNameInContainer = function(element, nodeName, rootElementId) {
    if (element.nodeName == nodeName) {
        return element;
    } else {
        if (element.id === rootElementId) {
            return null;
        }
        _findNodeByNameInContainer(element.parentElement, nodeName, rootElementId);
    }
};

var isAnchorNode = function(node) {
    return ("A" == node.nodeName);
};

RE.getAnchorTagsInNode = function(node) {
    var links = [];
    
    while (node.nextSibling !== null && node.nextSibling !== undefined) {
        node = node.nextSibling;
        if (isAnchorNode(node)) {
            links.push(node.getAttribute('href'));
        }
    }
    return links;
};

RE.countAnchorTagsInNode = function(node) {
    return RE.getAnchorTagsInNode(node).length;
};

/**
 * If the current selection's parent is an anchor tag, get the href.
 * @returns {string}
 */
RE.getSelectedHref = function() {
    var href, sel;
    href = '';
    sel = window.getSelection();
    if (!RE.rangeOrCaretSelectionExists()) {
        return null;
    }
    
    var tags = RE.getAnchorTagsInNode(sel.anchorNode);
    //if more than one link is there, return null
    if (tags.length > 1) {
        return null;
    } else if (tags.length == 1) {
        href = tags[0];
    } else {
        var node = _findNodeByNameInContainer(sel.anchorNode.parentElement, 'A', 'editor');
        href = node.href;
    }
    
    return href ? href : null;
};

// Returns the cursor position relative to its current position onscreen.
// Can be negative if it is above what is visible
RE.getRelativeCaretYPosition = function() {
    var y = 0;
    var sel = window.getSelection();
    if (sel.rangeCount) {
        var range = sel.getRangeAt(0);
        var needsWorkAround = (range.startOffset == 0)
        /* Removing fixes bug when node name other than 'div' */
        // && range.startContainer.nodeName.toLowerCase() == 'div');
        if (needsWorkAround) {
            y = range.startContainer.offsetTop - window.pageYOffset;
        } else {
            if (range.getClientRects) {
                var rects=range.getClientRects();
                if (rects.length > 0) {
                    y = rects[0].top;
                }
            }
        }
    }
    
    return y;
};

RE.getSelectionCharOffsetsWithin = function() {
    let start = 0, end = 0;
    let sel, range, priorRange;
    let element = document.getElementById("main");
    if (typeof window.getSelection != "undefined") {
        range = window.getSelection().getRangeAt(0);
        priorRange = range.cloneRange();
        priorRange.selectNodeContents(element);
        priorRange.setEnd(range.startContainer, range.startOffset);
        start = priorRange.toString().length;
        end = start + range.toString().length;
    } else if (typeof document.selection != "undefined" &&
               (sel = document.selection).type != "Control") {
        range = sel.createRange();
        priorRange = document.body.createTextRange();
        priorRange.moveToElementText(element);
        priorRange.setEndPoint("EndToStart", range);
        start = priorRange.text.length;
        end = start + range.text.length;
    }
    let string = start + ":" + end;
    return string;
};
