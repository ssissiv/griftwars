    -- reference for imgui usage.
    
    -- Debug window
    imgui.Text("Hello, world!");
    status, clearColor[1], clearColor[2], clearColor[3] = imgui.ColorEdit3("Clear color", clearColor[1], clearColor[2], clearColor[3]);
 
    -- Sliders
    status, floatValue = imgui.SliderFloat("SliderFloat", floatValue, 0.0, 1.0);
    status, sliderFloat[1], sliderFloat[2] = imgui.SliderFloat2("SliderFloat2", sliderFloat[1], sliderFloat[2], 0.0, 1.0);
 
    -- Combo
    status, comboSelection = imgui.Combo("Combo", comboSelection, { "combo1", "combo2", "combo3", "combo4" }, 4);
 
    -- Windows
    if imgui.Button("Test Window") then
        showTestWindow = not showTestWindow;
    end
 
    if imgui.Button("Another Window") then
        showAnotherWindow = not showAnotherWindow;
    end
 
    if showAnotherWindow then
        imgui.SetNextWindowPos(50, 50, "FirstUseEver")
        status, showAnotherWindow = imgui.Begin("Another Window", true, { "AlwaysAutoResize", "NoTitleBar" });
        imgui.Text("Hello");
        -- Input text
        status, textValue = imgui.InputTextMultiline("InputText", textValue, 200, 300, 200);
        imgui.End();
    end
 
    if showTestWindow then
        showTestWindow = imgui.ShowTestWindow(true)
    end
 