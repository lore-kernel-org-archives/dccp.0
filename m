From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 23 Aug 2007 08:43:28 +0000
Subject: [RFC] DCCP Faster Restart
Message-Id: <5640c7e00708230143w17881e75va19572e6f7eb3af0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch series implements much of TFRC faster restart as per
draft-ietf-dccp-tfrc-faster-restart-03.txt

and with changes from:
http://www3.ietf.org/proceedings/07jul/slides/dccp-6.pdf

Most notably we don't do pings and a few other bits and pieces.

I've posted this up at:
http://wand.net.nz/~iam4/dccp/patches24/
(Ignore patch 7).

If anybody is interested they are most welcome to look at.

This patch series has been tested but will undergo more work yet
before I ask Gerrit to put into tree and before I post as patches to
this list:
- check that it applies against very latest tree
- do some performance testing
- rework the socket options code a bit so we can do socket options
without parameters (in the meantime pass a dummy parameter rather than
null)

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
