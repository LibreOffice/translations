# -*- Mode: makefile-gmake; tab-width: 4; indent-tabs-mode: t -*-
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
# Major Contributor(s):
# Copyright (C) 2012 Matúš Kukan <matus.kukan@gmail.com> (initial developer)
#
# All Rights Reserved.
#
# For minor contributions see the git repository.
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 3 or later (the "GPLv3+"), or
# the GNU Lesser General Public License Version 3 or later (the "LGPLv3+"),
# in which case the provisions of the GPLv3+ or the LGPLv3+ are applicable
# instead of those above.

$(eval $(call gb_CustomTarget_CustomTarget,translations/translate))

translations_DIR := $(call gb_CustomTarget_get_workdir,translations/translate)

$(call gb_CustomTarget_get_target,translations/translate) : \
	$(translations_DIR)/pot.done

$(translations_DIR)/pot.done : $(foreach exec,cfgex helpex localize transex3 \
                                         propex uiex ulfex xrmex treex, \
			$(call gb_Executable_get_target_for_build,$(exec)))
	$(call gb_Output_announce,$(subst .pot,,$(subst $(WORKDIR)/,,$@)),$(true),POT,1)
	$(call gb_Helper_abbreviate_dirs, \
		mkdir -p $(dir $@) && $(call gb_Helper_execute,localize) $(SRCDIR) $(dir $@)/pot) \
		&& find $(dir $@)/pot -type f -printf "%P\n" | sed -e "s/\.pot/.po/" > $(dir $@)/LIST \
		&& touch $@

# vim: set noet sw=4 ts=4:
