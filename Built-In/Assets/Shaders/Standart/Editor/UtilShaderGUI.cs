using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class UtilShaderGUI : ShaderGUI
{
    
    protected Material target;
    protected MaterialEditor editor;
    protected MaterialProperty[] properties;

    protected virtual void Update()
    {
        
    }
    
    //GUI Update
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        editor = materialEditor;
        this.properties = properties;
        target = editor.target as Material;
        Update();        
    }
    
    
    MaterialProperty FindProperty(string propertyName) => FindProperty(propertyName, properties);

    protected void SingleLineTexture(string texProp, string otherProp = null, bool scaleOffset = false, string tooltip = null,
        string displayName = null)
    {
        MaterialProperty tex = FindProperty(texProp);
        string labelText = displayName ?? tex.displayName;
        GUIContent label = new GUIContent(labelText, tooltip);
        
        if (string.IsNullOrEmpty(otherProp)) 
            editor.TexturePropertySingleLine(label, tex);
        else 
            editor.TexturePropertySingleLine(label, tex, FindProperty(otherProp));
        
        if (scaleOffset) 
            editor.TextureScaleOffsetProperty(tex);
    }

    protected void Property(string propertyName, string tooltip = null, int labelIndent = 0)
    {
        MaterialProperty materialProperty = FindProperty(propertyName);
        GUIContent label = new GUIContent(materialProperty.displayName, tooltip);
        editor.ShaderProperty(materialProperty, label, labelIndent);
    }
    
    protected T GetKeyword<T>(Dictionary<T, string> keywords) where T : Enum
    {
        T[] types = (T[])Enum.GetValues(typeof(T));
        T toSet = types.ToList().Find(t => !keywords.Keys.Contains(t));
        foreach (KeyValuePair<T, string> kvp in keywords)
        {
            if (target.IsKeywordEnabled(kvp.Value)) toSet = kvp.Key;
        }
        return toSet;
    }
    protected void KeywordDropdown<T>(Dictionary<T, string> keywords, T current, 
        string displayName = null, string tooltip = null) where T : Enum
    {
        GUIContent label = new GUIContent(displayName, tooltip);
        EditorGUI.BeginChangeCheck();
        current = (T)EditorGUILayout.EnumPopup(label, current);
        if (EditorGUI.EndChangeCheck())
        {
            foreach (KeyValuePair<T, string> kvp in keywords)
            {
                if (kvp.Key.Equals(current)) target.EnableKeyword(kvp.Value);
                else target.DisableKeyword(kvp.Value);
            }
        }
    }
    protected void KeywordDropdown<T>(Dictionary<T, string> keywords, string displayName = null, 
        string tooltip = null) where T : Enum
    {
        T current = GetKeyword<T>(keywords);
        KeywordDropdown<T>(keywords, current, displayName, tooltip);
    }

    protected void KeywordToggle(string keyword, string label)
    {
        bool bProp = target.IsKeywordEnabled(keyword);
        EditorGUI.BeginChangeCheck();
        bProp = EditorGUILayout.Toggle(label, bProp);
        if (EditorGUI.EndChangeCheck())
        {
            if(bProp)
                    target.EnableKeyword(keyword);
            else
                target.DisableKeyword(keyword);
        }
    }

    protected bool IsVisible(string propertyName)
    {
        MaterialProperty showProp = FindProperty(propertyName);
        bool show = EditorGUILayout.Toggle(showProp.displayName, showProp.floatValue == 1);
        showProp.floatValue = show ? 1 : 0;
        return show;
    }
}
