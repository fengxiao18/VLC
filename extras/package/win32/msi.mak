if HAVE_WIN32
BUILT_SOURCES_distclean += \
	extras/package/win32/msi/config.wxi
endif

WIXPATH=`wine winepath -u 'C:\\Program Files (x86)\\Windows Installer XML v3.5\\bin'`
HEAT=wine "$(WIXPATH)/heat.exe"
CANDLE=wine "$(WIXPATH)/candle.exe"
LIGHT=wine "$(WIXPATH)/light.exe"
VLCDIR=`wine winepath -s \`wine winepath -w '$(abs_top_builddir)/vlc-$(VERSION)'\``
MSIDIR=$(abs_srcdir)/extras/package/win32/msi
W_MSIDIR=`wine winepath -w '$(MSIDIR)'`
MSIBUILDDIR=$(abs_top_builddir)/extras/package/win32/msi
W_MSIBUILDDIR=`wine winepath -w '$(MSIBUILDDIR)'`
if HAVE_WIN64
MSIOUTFILE=vlc-$(VERSION)-win64.msi
else
MSIOUTFILE=vlc-$(VERSION)-win32.msi
endif
W_WINE_C=c:/v
WINE_C=`wine winepath $(W_WINE_C)`

heat: package-win-strip
	$(HEAT) dir $(VLCDIR)/plugins -cg CompPluginsGroup -gg -scom -sreg -sfrag -dr APPLICATIONFOLDER -out $(W_MSIBUILDDIR)/Plugins.fragment.wxs
	$(HEAT) dir $(VLCDIR)/locale -cg CompLocaleGroup -gg -scom -sreg -sfrag -dr APPLICATIONFOLDER -out $(W_MSIBUILDDIR)/Locale.fragment.wxs
if BUILD_LUA
	$(HEAT) dir $(VLCDIR)/lua -cg CompLuaGroup -gg -scom -sreg -sfrag -dr APPLICATIONFOLDER -out $(W_MSIBUILDDIR)/Lua.fragment.wxs
endif
if BUILD_SKINS
	$(HEAT) dir $(VLCDIR)/skins -cg CompSkinsGroup -gg -scom -sreg -sfrag -dr APPLICATIONFOLDER -out $(W_MSIBUILDDIR)/Skins.fragment.wxs
endif

candle: heat
	$(am__cd) $(MSIBUILDDIR) && $(CANDLE) -arch $(WINDOWS_ARCH) -ext WiXUtilExtension $(W_MSIDIR)/product.wxs $(W_MSIDIR)/axvlc.wxs $(W_MSIDIR)/extensions.wxs $(W_MSIBUILDDIR)/*.fragment.wxs

$(MSIOUTFILE): candle
	test ! -d "$(WINE_C)" -o ! -f "$(WINE_C)"
	ln -Tsf "$(abs_top_builddir)/vlc-$(VERSION)" "$(WINE_C)"
	$(AM_V_GEN)$(LIGHT) -sval -spdb -ext WixUIExtension -ext WixUtilExtension -cultures:en-us -b $(W_MSIDIR) -b $(W_WINE_C)/plugins -b $(W_WINE_C)/locale -b $(W_WINE_C)/lua -b $(W_WINE_C)/skins $(W_MSIBUILDDIR)/product.wixobj $(W_MSIBUILDDIR)/axvlc.wixobj $(W_MSIBUILDDIR)/extensions.wixobj $(W_MSIBUILDDIR)/*.fragment.wixobj -o $@
	chmod 644 $@

package-msi: $(MSIOUTFILE)

cleanmsi:
	-rm -f $(MSIBUILDDIR)/*.wixobj
	-rm -f $(MSIBUILDDIR)/*.wixpdb
	-rm -f $(MSIBUILDDIR)/*.fragment.wxs

distcleanmsi: cleanmsi
	-rm -f $(MSIOUTFILE)

.PHONY: heat candle cleanmsi distcleanmsi package-msi
