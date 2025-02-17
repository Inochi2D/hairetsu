/**
    Font Descriptors

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.descriptor;
import core.sys.windows.wingdi;
import numem;

/**
    The rendering orientation of the font 
    for calculating glyph metrics.
*/
enum FontOrientation {

    /**
        The native orientation for the font

        Note:
            This is used during font selection.
    */
    native,

    /**
        Font is horizontal.
    */
    horizontal,

    /**
        Font is vertical.
    */
    vertical
}

/**
    A descriptor for a font.

    During font lookup the descriptor is used to define specifically
    what you're looking for.

    After font lookup Font Descriptors will be returned containing
    information about the found fonts.
*/
final
class FontDescriptor : NuRefCounted {
@nogc:
private:
    string path_ = null;
    string fontName_ = null;
    string familyName_ = null;
    string displayName_ = null;
    string styleName_ = null;
    string variation_ = null;
    string[] languages_ = null;
    FontOrientation orientation_ = FontOrientation.native;

public:

    ~this() {

        // Ensures the memory is cleared before use.
        this.clear();
    }

    this() { }
    
    /**
        The path to the font.

        Notes:
            During font lookup this should be left be.
    */
    @property string path() { return path_; }
    @property void path(string value) {

        if (path_.length > 0 || value is null)
            path_ = path_.nu_resize(0);
        else 
            path_ = value.nu_dup();
    } /// ditto

    /**
        The PostScript name of the font
    */
    @property string fontName() { return fontName_; }
    @property void fontName(string value) {
        
        if (fontName_.length > 0 || value is null)
            fontName_ = fontName_.nu_resize(0);
        else 
            fontName_ = value.nu_dup();
    } /// ditto

    /**
        The name of the font family
    */
    @property string familyName() { return familyName_; }
    @property void familyName(string value) {
        
        if (familyName_.length > 0 || value is null)
            familyName_ = familyName_.nu_resize(0);
        else 
            familyName_ = value.nu_dup();
    } /// ditto

    /**
        The display name of the font
    */
    @property string displayName() { return displayName_; }
    @property void displayName(string value) {
        
        if (displayName_.length > 0 || value is null)
            displayName_ = displayName_.nu_resize(0);
        else 
            displayName_ = value.nu_dup();
    } /// ditto

    /**
        The name of the font style.
    */
    @property string styleName() { return styleName_;}
    @property void styleName(string value) {
        
        if (styleName_.length > 0 || value is null)
            styleName_ = styleName_.nu_resize(0);
        else 
            styleName_ = value.nu_dup();
    } /// ditto

    /**
        The variation of the font.
    */
    @property string variation() { return variation_; }
    @property void variation(string value) {
        
        if (variation_.length > 0 || value is null)
            variation_ = variation_.nu_resize(0);
        else 
            variation_ = value.nu_dup();
    } /// ditto

    /**
        The orientation of the font.
    */
    @property FontOrientation orientation() { return orientation_; }
    @property void orientation(FontOrientation value) { orientation_ = value; }

    /**
        A sequence of RFC 3066 language codes.
    */
    @property ref string[] languages() { return languages_; }

    /**
        Adds a RFC 3066 language code to the language list.

        Params:
            language = The language to add.
    */
    void addLanguage(string language) {
        languages_ = languages_.nu_resize(languages_.length+1);
        languages_[$-1] = language.nu_dup();
    }

    /**
        Clears the language list.
    */
    void clearLanguages() {
        if (languages_.ptr) {
            foreach(ref element; languages_) {
                element.nu_resize(0);
            }
            languages_ = languages_.nu_resize(0);
        }
    }

    /**
        Clears all state in the font descriptor.
    */
    void clear() {
        if (path_.ptr) path_ = path_.nu_resize(0);
        if (fontName_.ptr) fontName_ = fontName_.nu_resize(0);
        if (familyName_.ptr) familyName_ = familyName_.nu_resize(0);
        if (displayName_.ptr) displayName_ = displayName_.nu_resize(0);
        if (styleName_.ptr) styleName_ = styleName_.nu_resize(0);
        if (variation_.ptr) variation_ = variation_.nu_resize(0);
        this.clearLanguages();

        orientation_ = FontOrientation.native;
    }
}

/**
    A descriptor set, holding font descriptors to look up.
*/
final
class FontDescriptorSet : NuRefCounted {
@nogc:
private:
    FontDescriptor[] descriptors;

    size_t grow(size_t amount = 1) {
        size_t oldLength = descriptors.length;
        descriptors = descriptors.nu_resize(oldLength+amount);
        return oldLength;
    }

public:

    /**
        The amount of descriptors stored in the descriptor set.
    */
    @property uint count() { return descriptors.length; }

    /**
        A slice of the descriptors stored in the descriptor
        set.
    */
    @property FontDescriptor[] descriptors() { return descriptors; }

    // Destructor.
    ~this() {
        foreach(ref descriptor; descriptors) {
            descriptor.release();
        }
    }

    /**
        Constructs an empty descriptor set.
    */
    this() { }

    /**
        Adds a descriptor to the descriptor set.

        Params:
            descriptor = the descriptor to add.
    */
    void add(FontDescriptor descriptor) {
        size_t idx = this.grow(1);
        descriptors[idx] = descriptor;
    }

    /**
        Adds a descriptor to the descriptor set.

        Params:
            descriptor = the descriptor to add.
    */
    void add(FontDescriptor[] descriptors) {
        size_t start = this.grow(descriptors.length);
        this.descriptors[start..$] = descriptors[0..$];
    }

    /**
        Loads the font described by the descriptor set.

        Note:
            This function will only work after font lookup has occured,
            or if you set $(D path) manually.

        Returns:
            A $(D FontFace) containing the font, $(D null) if the font wasn't found.
    */
    FontFace load() {
        if (path.length > 0)
            return nogc_new!FontFace(path);
        return null;
    }
}
