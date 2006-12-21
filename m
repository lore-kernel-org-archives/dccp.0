From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 13:26:14 +0000
Subject: Re: [PATCH 3/5]: DCCP Add to debugging
Message-Id: <200612211326.15038@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201547.04753.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201547.04753.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As said - I am not very happy about the huge number of debugging
statements (the ratio debug <-> pure code is  much higher than in all other source files),
but if it helps to find issues at the moment, then it is useful.

|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
