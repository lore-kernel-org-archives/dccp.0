From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 23:11:24 +0000
Subject: Re: [PATCH 5/6]: Add history query/lookup function
Message-Id: <5640c7e00706161611q7aec5cbave3bc9daec5f04688@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706111342.02233@strip-the-willow>
In-Reply-To: <200706111342.02233@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/17/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 6/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > [TFRC]: Add history query/lookup function
> >
> > This completes the basic TX history functions that are implemented by this
> > patch set, by adding a lock-protected lookup function to look up the send
> > time of a particular sent packet.
>
> I notice there is other functionality here also...
>
And I see why from the following patch now. Perhaps you could add
something to commit description to elude to this.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
