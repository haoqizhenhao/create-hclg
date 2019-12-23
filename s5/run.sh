#!/bin/bash

# Copyright 2019 Authors: Hao Qi

# Apache 2.0

# This is a shell script, but it's recommended that you run the commands one by
# one by copying and pasting into the shell.
# Caution: some of the graph creation steps use quite a bit of memory, so you
# should run this on a machine that has sufficient memory.

# Lexicon Preparation
#自己准备发音字典lexicon.txt,放在data/dict中

# Data Preparation,
#自己准备text文件，用于语言模型的训练，data/目录下

# am-model Preparation
# 准备声学模型，放在exp/chain/tdnn中（根据不同模型，路径不同）
# Phone Sets, questions, L compilation
#根据发音字典，生成L.fst，过程文件保存在data/local/lang，生成文件保存在data/lang中
utils/prepare_lang.sh --position-dependent-phones false data/dict \
    "<SPOKEN_NOISE>" data/local/lang data/lang || exit 1;

# LM training
#训练语言模型，生成data/local/lm/3gram-mincount/lm_unpruned.gz
local/aishell_train_lms.sh || exit 1; 

# G compilation, check LG composition 
#根据上一步文件生成G.fst,保存在lang_text中
utils/format_lm.sh data/lang data/local/lm/3gram-mincount/lm_unpruned.gz \
    data/dict/lexicon.txt data/lang_test || exit 1;

#根据G.fst L.fst 及final.mdl文件生成HCLG.fst
utils/mkgraph.sh data/lang_test exp/chain/tdnn exp/chain/tdnn/graph || exit 1;

exit 0;
