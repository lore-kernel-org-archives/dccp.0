From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:30:10 +0000
Subject: [PATCH 1-6/8 and 8/8]: The more recent patches of the backlog
Message-Id: <200701031330.10330@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I think it is not necessary to resend those patches which have not changed.
Thus links to the online repository are given instead.

(NB: in case of DNS difficulties, the online repository is at
     http://139.133.210.30/users/gerrit/dccp/patch-backlog/            )


Patch 1: Remove redundant `len' test.
         First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01163.html
         Online at      : 2b_ccid3_tx-len-not-needed.diff

Patch 2: Re-order CCID 3 source file
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01164.html
	 Online at      : 2c_re-order-ccid3.c.diff

Patch 3: Use MSS for larger initial windows
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01165.html
	 Online at      : 2d_larger_windows_with_MSS.diff

Patch 4: Fix use of invalid loss intervals [by Ian McDonald]
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01150.html
	 Online at      : 3a_fix_use_of_invalid_li_McDonald.diff

Patch 5: More verbose debugging [by Ian McDonald]
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01229.html
	 Online at 	: 3c_CCID3_add_more_debugging_McDonald.diff
         => online version has fixes which were pointed out at
             http://www.mail-archive.com/dccp@vger.kernel.org/msg01235.html

Patch 6: Fix packet tardiness BUG
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01216.html
	 Online at      : 3d_CCID3_fix_tardiness-BUG.diff

Patch 7: Remove race condition in access to scheduled send time
	 Will be submitted hereafter.

Patch 8: Reorganise loss interval code
	 First posted on: http://www.mail-archive.com/dccp@vger.kernel.org/msg01218.html
	 Online at      : 3f_CCID3_refactor_loss_interval_code_McDonald.diff


