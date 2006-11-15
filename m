From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Nov 2006 17:34:42 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <200611151734.42999@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
In-Reply-To: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Anyway I'll have a look at it as I can but feel free to make patches.
|  If you're removing chunks of code I'd prefer it commented out in the
|  meantime rather than removed.
Thanks - I was hoping for your answer. To me it seemed that the bidirectional
processing (node is both receiver and sender) is not supported at the moment
and that therefore it would make sense to keep tx/rx functionality separate.

Gerrit
