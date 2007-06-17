From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 10:26:38 +0000
Subject: Re: [PATCH 5/6]: Add history query/lookup function
Message-Id: <200706171126.38396@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706111342.02233@strip-the-willow>
In-Reply-To: <200706111342.02233@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  And I see why from the following patch now. Perhaps you could add
|  something to commit description to elude to this.
Ah coming through to this one - I just answered the other email:)

Yes, I have changed the commit message as follows:

"Note: When the lookup is successful, the function automatically garbage-collects
       older entries (which become at that point useless/irrelevant). 
       This is done outside the lock, to keep lock times to a minimum."


Thanks for going through the patches, I am glad for the feedback.
