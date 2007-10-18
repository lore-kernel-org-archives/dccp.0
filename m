From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Oct 2007 08:56:51 +0000
Subject: Re: CONFLICT using git-pull
Message-Id: <200710180956.51870@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
In-Reply-To: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

It is not necessary to pull the git tree for the DCCP patches - they are
all available as a single patch:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/

|  FYI, I started to use git-gui and it seems to be very helpful, but I'm
|  still using quilt/gquilt to finish the patches series for ccid3/ccid4
|  integration.
|  
|  2007/9/20, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
|  > |  You said that will define a specific frequency
|  > |  (for instance, every week) that you will do this. Did you already
|  > |  define it?
|  > The repository is synced normally every working day from Mon .. Fri,
|  > based on the davem-2.6 tree - not the one used for the merge windows.
|  > -
|  > To unsubscribe from this list: send the line "unsubscribe dccp" in
|  > the body of a message to majordomo@vger.kernel.org
|  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  >
|  
|  
