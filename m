From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 06 Oct 2008 04:14:13 +0000
Subject: Re: v2 [PATCH 0/5] dccp: Feature negotiation, Part I - Underlying
Message-Id: <20081006041413.GA3762@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1223111606-5308-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1223111606-5308-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| You have to split up your patches more intelligently, such that they
| are fully bisectable and at each patch point there are no new warnings
| or known bugs added.
| 
OK will do. I understand that this means resubmitting the full set.
