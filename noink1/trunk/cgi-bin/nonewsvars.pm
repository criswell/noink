# nonewsvars.pm
# -------------
# NoNews Static Variables
#
#    Copyright (C) 2000 Sam Hart
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

####################
# Global constants

$default_str = 'default';
$no = 'no';
$yes = 'yes';

####################
# HTML Definitions

$HTML_whitespace = '&nbsp;';

####################
# Parameter varis

$param_cmd = 'cmd';
$param_read = 'read';
$param_max = 'max';
$param_new = 'new';
$param_num = 'num';
$param_dir = 'dir';
$param_info = 'info';
$param_name = 'name';
$param_search = 'search';
$param_bytopic = 'bytopic';
$param_bykeywords = 'bykeys';
$param_conf_prefix = 'prefix';
$param_more = 'more';

####################
# Cookie types

$cookie_theme = 'sitetheme';

########################
# HTML meta-tags

@HTML_metas = ( 'author', 'classification', 'description', 'keywords', 'rating', 'copyright', 'language', 'doc-type', 'doc-class', 'doc-rights', 'resource-type' );
@BODY_metas = ( 'bgcolor', 'text', 'vlink', 'link', 'background' );
@Table_metas = ( 'border', 'cellspacing', 'cols', 'width', 'bgcolor', 'background', 'cellpadding' );
@TR_metas = ( 'valign', 'align', 'bgcolor', 'background' );
@TD_metas = ( 'valign', 'align', 'width', 'rowspan', 'bgcolor' );

####################
# CSS Style types

$CSS_TitleLink = ".titlelink";
$CSS_AuthorLink = ".authorlink";
$CSS_DateLink = ".datelink";
$CSS_BorderLink = ".borderlink";
$CSS_MoreLink = ".morelink";

####################
# Filenames et al

$file_passwords = "NoNews.pass";

####################
# NoML meta-tags


$noml_title = 'title';
$noml_css = 'css';
$noml_MainTable = 'maintable';
$noml_BreakingNews = 'breakingnews';
$noml_HeadLines = 'headlines';
$noml_LoginBox = 'loginbox';
$noml_TR = 'tr';
$noml_TD = 'td';
$noml_fontface = 'fontface';
$noml_cols = 'cols';
$noml_rows = 'rows';
$noml_data = 'data';
$noml_date = 'date';
$noml_author = 'author';
$noml_topic = 'topic';
$noml_title = 'title';
$noml_keywords = 'keywords';
$noml_owner = 'owner';
$noml_user = 'user';
$noml_group = 'group';
$noml_borderw = 'borderw';
$noml_borderc = 'borderc'; # can be an array for multi-colors
$noml_layout = 'layout';
$noml_head = 'head';
$noml_body = 'body';
$noml_post = 'post';
$noml_more = 'more';
$noml_lines = 'lines';
$noml_width = 'width';
$noml_max = 'max';
$noml_bgcolor = 'bgcolor';
$noml_textcolor = 'textcolor';
$noml_bordertextcolor = 'bordertextcolor';

;