From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 18 Oct 2007 16:17:50 +0000
Subject: Re: [PATCH v2 1/1]: Collect all scattered sysctl variables into sysctl.c
Message-Id: <5640c7e00710180917k3c320168t105bfb6b44597adc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710181230.56399@strip-the-willow>
In-Reply-To: <200710181230.56399@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/19/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is an update with regard to the latest netdev-2.6 tree, the main
> change is that the sysctl_dccp_sync_ratelimit is also moved into sysctl.c
> (the sysctl variables are now from 4 different files, previously 3).
>
> Ian please check if you are still okay with the Signed-off.

Yes I am.
