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

.IF "$(OS_FOR_BUILD)"=="WNT" || ("$(SYSTEM_PYTHON)"!="YES" && "$(OS)" != "MACOSX")
# watch for the path delimiter
.IF "$(OS_FOR_BUILD)"=="WNT"
PYTHONPATH:=$(PWD)$/$(BIN);$(SOLARLIBDIR);$(SOLARLIBDIR)$/python;$(SOLARLIBDIR)$/python$/lib-dynload
.ELSE
PYTHONPATH:=$(PWD)$/$(BIN):$(SOLARLIBDIR):$(SOLARLIBDIR)$/python:$(SOLARLIBDIR)$/python$/lib-dynload
.ENDIF
.EXPORT: PYTHONHOME
.EXPORT: PYTHONPATH
PYTHONCMD=$(AUGMENT_LIBRARY_PATH) $(WRAPCMD) $(SOLARBINDIR)/python
.ELSE
PYTHONCMD=$(WRAPCMD) $(PYTHON)
.ENDIF

.IF "$(WITH_LANG)" == "ALL"
    all_languages:=$(shell cd $(PRJ)/source && ls -1)
.ELSE
    all_languages:=$(WITH_LANG:s/en-US//)
.ENDIF			# "$(WITH_LANG)" == "ALL"

$(MISC)/sdf-template/en-US.sdf :
    -$(MKDIRHIER) $(MISC)/sdf-template
    -$(MKDIRHIER) $(MISC)/sdf-l10n
.IF "$(OS)" == "WNT" 
    $(SOLARSRC)/solenv/bin/localize -f $(shell cygpath -m $(SRC_ROOT)/$(PRJNAME)/$@)
.ELSE
    $(SOLARSRC)/solenv/bin/localize -f $(SRC_ROOT)/$(PRJNAME)/$@
.ENDIF                  # "$(OS)" == "WNT" 

pot : $(MISC)/sdf-template/en-US.sdf
    $(OO2PO) -P -i $< -o $(MISC)/pot
    $(PERL) $(SOLARBINDIR)/addkeyid2pot.pl $(MISC)/pot

$(MISC)/sdf-l10n/%.sdf : $(MISC)/sdf-template/en-US.sdf
    $(PYTHONCMD) $(SOLARBINDIR)/po2lo --skipsource -i $(PRJ)/source/$(@:b) -t $(MISC)/sdf-template/en-US.sdf -o $@ -l $(@:b)

$(MISC)/sdf-l10n/qtz.sdf : $(MISC)/sdf-template/en-US.sdf
    $(PERL) $(SOLARBINDIR)/keyidGen.pl $< $@

$(MISC)/merge.done : $(foreach,i,$(all_languages) $(MISC)/sdf-l10n/$i.sdf) $(MISC)/sdf-l10n/qtz.sdf
.IF "$(L10N_LOCK)" != "YES"
    $(IFEXIST) $(MISC)/sdf $(THEN) $(RENAME) $(MISC)/sdf $(MISC)/sdf$(INPATH)_begone $(FI)
    -rm -rf $(MISC)/sdf$(INPATH)_begone
    -$(MKDIRHIER) $(MISC)/sdf
.ENDIF			# "$(L10n_LOCK)" != "YES"
    $(PERL) $(SOLARBINDIR)/fast_merge.pl -sdf_files $(mktmp $<) -merge_dir $(MISC)/sdf && $(TOUCH) $@
    $(COPY) $(PRJ)/localization_present.mk $(PRJ)/$(COMMON_OUTDIR)$(PROEXT)/inc

ALLTAR : $(MISC)/merge.done

.ENDIF
