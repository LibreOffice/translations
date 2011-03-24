#*************************************************************************
#
# Version: MPL 1.1 / GPLv3+ / LGPLv3+
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License or as specified alternatively below. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Initial Developer of the Original Code is
# Andras Timar <timar@fsf.hu>
# Portions created by the Initial Developer are Copyright (C) 2010 the
# Initial Developer. All Rights Reserved.
#
# Major Contributor(s): 
# Ted <ted@bear.com>
# Portions created by the Ted are Copyright (C) 2010 Ted. All Rights Reserved.
#
# For minor contributions see the git repository.
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 3 or later (the "GPLv3+"), or
# the GNU Lesser General Public License Version 3 or later (the "LGPLv3+"),
# in which case the provisions of the GPLv3+ or the LGPLv3+ are applicable
# instead of those above.
#
#*************************************************************************

PRJ=.
PRJNAME=translations
TARGET=translations_merge

# --- Targets ------------------------------------------------------
.INCLUDE : settings.mk

.INCLUDE .IGNORE : $(MISC)/sdf/lock.mk

.IF "$(WITH_LANG)" == ""

@all:
    @echo "Nothing to do - en-US only build."
.ELSE

.INCLUDE : target.mk

.IF "$(SYSTEM_TRANSLATE_TOOLKIT)" != "YES"

OO2PO=$(AUGMENT_LIBRARY_PATH) $(WRAPCMD) $(SOLARBINDIR)/oo2po
PO2OO=$(AUGMENT_LIBRARY_PATH) $(WRAPCMD) $(SOLARBINDIR)/po2oo

TRANSLATE_TOOLKIT_PYTHONPATH=$(SOLARLIBDIR)$/translate_toolkit
.IF "$(SYSTEM_PYTHON)" == "YES"
PYTHONPATH:=$(TRANSLATE_TOOLKIT_PYTHONPATH)
.ELSE
PYTHONPATH:=$(SOLARLIBDIR)/python:$(TRANSLATE_TOOLKIT_PYTHONPATH)
.ENDIF
.EXPORT: PYTHONPATH

.ELSE                   # "$(SYSTEM_PYTHON)"!="YES"

OO2PO=$(AUGMENT_LIBRARY_PATH) $(WRAPCMD) oo2po
PO2OO=$(AUGMENT_LIBRARY_PATH) $(WRAPCMD) po2oo

.ENDIF                  # "$(SYSTEM_PYTHON)"!="YES"

.IF "$(WITH_LANG)" == "ALL"
    all_languages:=$(shell cd $(PRJ)/source && ls -1)
.ELSE
    all_languages:=$(WITH_LANG:s/en-US//)
.ENDIF			# "$(WITH_LANG)" == "ALL"

$(MISC)/sdf-template/en-US.sdf :
    -$(MKDIRHIER) $(MISC)/sdf-template
    -$(MKDIRHIER) $(MISC)/sdf-l10n
    $(SOLARSRC)/solenv/bin/localize -e -l en-US -f $(SRC_ROOT)/$(PRJNAME)/$@

pot : $(MISC)/sdf-template/en-US.sdf
    $(OO2PO) -P -i $< -o $(MISC)/pot

$(MISC)/sdf-l10n/%.sdf : $(MISC)/sdf-template/en-US.sdf
.IF "$(WITH_LANG)" == "kid"
    $(PERL) $(SOLARVER)/$(INPATH)/bin$(UPDMINOREXT)/keyidGen.pl $< $@.tmp
    sed -e "s/\ten-US\t/\tkid\t/" < $@.tmp > $@
    rm -f $@.tmp
.ELSE
    $(PO2OO) -i $(PRJ)/source/$(@:b) -t $(MISC)/sdf-template/en-US.sdf -o $@ -l $(@:b)
# FIXME: waiting for fix of http://bugs.locamotion.org/show_bug.cgi?id=1883
# po2oo --skipsource -i $(PRJ)/source/$(@:b) -t $(MISC)/sdf-template/en-US.sdf -o $@ -l $(@:b)
    grep -v "	en-US	" $@ > $@.tmp
    mv $@.tmp $@
.ENDIF

$(MISC)/merge.done : $(foreach,i,$(all_languages) $(MISC)/sdf-l10n/$i.sdf)
.IF "$(L10N_LOCK)" != "YES"
    $(IFEXIST) $(MISC)/sdf $(THEN) $(RENAME) $(MISC)/sdf $(MISC)/sdf$(INPATH)_begone $(FI)
    -rm -rf $(MISC)/sdf$(INPATH)_begone
    -$(MKDIRHIER) $(MISC)/sdf
.ENDIF			# "$(L10n_LOCK)" != "YES"
    $(PERL) $(SOLARVER)/$(INPATH)/bin$(UPDMINOREXT)/fast_merge.pl -sdf_files $(mktmp $<) -merge_dir $(MISC)/sdf && $(TOUCH) $@
    $(COPY) $(PRJ)/localization_present.mk $(PRJ)/$(COMMON_OUTDIR)$(PROEXT)/inc

ALLTAR : $(MISC)/merge.done

.ENDIF
