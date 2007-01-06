From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 06 Jan 2007 22:58:53 +0000
Subject: [PATCH 0/1] Fix for t_nom
Message-Id: <200701071158.54225.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The following patch fixes this area up to be much better I believe.

I went back to the definition in the RFC and based my code on this.

This removes the need for my earlier patch and Gerrit's race patch and
tardiness patch.

Applies in the order listed in my website - the ones with the same name as
Gerrit's mean I'm using identical patches to him.

Ian
