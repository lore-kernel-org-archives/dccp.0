From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 02 Sep 2009 02:44:04 +0000
Subject: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

First Patch on TFRC-SP. Does a copy from TFRC and adjust symbols name
with infix "_sp".
Also updates Kconfig and init/exit code. An #ifndef was added to headers that
have commom symbols with TFRC that were not changed, so they don't get
included twice.


Following the rule #8 in Documentation/SubmittingPatches the patch is
stored at http://embedded.ufcg.edu.br/~ivocalado/dccp/patches_tfrc_sp/tfrc_sp_receiver_00.patch
