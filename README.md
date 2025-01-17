Τμήμα Τεχνών Ήχου και Εικόνας 

Ιόνιο Πανεπιστήμιο 

 

 

 

 

ΔΙΑΔΡΑΣΤΙΚΑ ΣΥΣΤΗΜΑΤΑ ΗΧΟΥ 

 

 

 

 

 

Αικατερίνη Στάντσεβ 

 ΤΧ2019074 

Κέρκυρα 2024 

 

 

 

 

  

  

Για τη δημιουργία αυτής της σύνθεσης στο SuperCollider, ακολούθησα μια πολύπλευρη διαδικασία προγραμματισμού και πειραματισμού, με στόχο να συνδυάσω ρυθμούς, εφέ, και γκρανουλαρική σύνθεση(granular synthesis)1 χρησιμοποιώντας διάφορες ηχητικές πηγές. Ένα από τα κύρια στοιχεία της σύνθεσης ήταν τα δύο ηχητικά αρχεία που χρησιμοποίησα, `Samples_StringsHigh.wav` και `Samples_PercDry.wav`, τα οποία ενσωματώθηκαν μέσω της φόρτωσής τους ως buffers στο SuperCollider. 

Η βασική έμπνευση για τη σύνθεση προήλθε από το βιβλίο "The SuperCollider Book", που προσφέρει λεπτομερείς περιγραφές των τεχνικών ηχητικής σύνθεσης, καθώς και των εργαλείων του SuperCollider. Εξίσου σημαντικό βοήθημα ήταν το εγχειρίδιο "A Gentle Introduction to SuperCollider" του Bruno Ruviaro, που εξηγεί τις βασικές αρχές του προγραμματισμού με απλό και κατανοητό τρόπο. Με τη μελέτη αυτών των πηγών, έμαθα πώς να δημιουργώ SynthDefs(συνθετικούς ορισμούς), να ορίζω παραμέτρους, όπως το `\rate`, το `\dur`, και να δημιουργώ σύνθετες αλληλουχίες ηχητικών συμβάντων. 

Επιπλέον, εμπνεύστηκα από βίντεο στο YouTube για τη δημιουργία ρυθμικών μοτίβων και πειραματικών ήχων. Τα βίντεο αυτά παρείχαν πρακτικά παραδείγματα για τον τρόπο κατασκευής διαφόρων τύπων ρυθμών και μου έδωσαν ιδέες για τον τρόπο με τον οποίο θα μπορούσα να εφαρμόσω εφέ, όπως `delay` και `reverb`, για να προσθέσω βάθος στη σύνθεσή μου. 

Εξίσου σημαντική ήταν και η μελέτη των κειμένων του Καθηγητη Ιωαννη Ζαννου, τα οποία παρουσιάζουν τις βασικές αρχές της γλώσσας, όπως η χρήση αντικειμένων (objects), μηνυμάτων (messages), μεθόδων (methods), και κλάσεων (classes). Η κατανόηση αυτών των εννοιών ήταν καθοριστική για το πώς θα προσεγγίσω τη σύνθεση και το πώς θα οργανώσω τον κώδικά μου. Ο τρόπος με τον οποίο το SuperCollider χειρίζεται την επικοινωνία μεταξύ του προγραμματιστικού περιβάλλοντος και του server (scsynth) ήταν επίσης σημαντικός, καθώς έπρεπε να κατανοήσω τον ρόλο του server στην παραγωγή και επεξεργασία του ήχου. 

 

Ένα από τα πρώτα ζητήματα που αντιμετώπισα ήταν πώς να συνδυάσω τον πειραματικό ήχο της γκρανουλαρικής σύνθεσης με ένα πιο παραδοσιακό ρυθμικό υπόβαθρο. Ξεκίνησα με τη φόρτωση των αρχείων `Samples_StringsHigh.wav` και `Samples_PercDry.wav` χρησιμοποιώντας την εντολή `Buffer.readChannel`. Έπρεπε να κατανοήσω πώς λειτουργούν τα buffers και πώς μπορώ να τα χρησιμοποιήσω για τη δημιουργία των διάφορων `SynthDefs`. 

  

```supercollider 

// Φόρτωση των buffers 

~b = Buffer.readChannel(s, "/mnt/data/Samples_StringsHigh.wav", channels: 1); 

~c = Buffer.readChannel(s, "/mnt/data/Samples_PercDry.wav", channels: 1); 

``` 

  

Με αυτή την εντολή, κατάφερα να φορτώσω τα ηχητικά δείγματα και να τα προετοιμάσω για χρήση σε γκρανουλαρικά μοτίβα και ρυθμούς. Στη συνέχεια, δημιούργησα διάφορα SynthDefs για να πειραματιστώ με τους ήχους. Ένα από τα SynthDefs που ανέπτυξα ήταν το `GranularStrLegato`, όπου χρησιμοποίησα τον αντικειμενοστραφή χαρακτήρα του SuperCollider για να ορίσω τα περιβλήματα (envelopes) του ήχου: 

  

```supercollider 

SynthDef.new(\GranularStrLegato, {arg bufnum, amp=1.0; 

    var tgrain, rateEnv, posEnv, ampEnv; 

     

    rateEnv = EnvGen.kr(Env.new(...), 1, levelScale: 1, doneAction: 2); 

    posEnv = EnvGen.kr(Env.new(...), 1, levelScale: 1, doneAction: 2); 

    ampEnv = EnvGen.kr(Env.new(...), 1, levelScale: 1, doneAction: 2); 

     

    tgrain = TGrains.ar(numChannels: 2, trigger: Impulse.kr(50), bufnum: bufnum, rate: rateEnv, centerPos: posEnv, dur: 0.25, pan: WhiteNoise.kr(1), amp: amp, interp: 4); 

    Out.ar(0, tgrain * ampEnv); 

}).load(s); 

 

Ανάλυση  
Στοιχείο Κώδικα 
Περιγραφή 
Βασικές Παράμετροι 
Φόρτωση Buffers 
Φορτώνει τα δείγματα ήχου στα buffers ~b και ~c χρησιμοποιώντας το Buffer.readChannel. Παρέχει πρόσβαση στα αρχεία ήχου για σύνθεση. 
Buffer.readChannel(s, '/mnt/data/Samples_StringsHigh.wav', channels: 1) 
SynthDef για Granular String Legato 
Ορίζει ένα SynthDef για έναν γκρανουλαρικό legato ήχο χρησιμοποιώντας ήχο από ένα buffer. Ελέγχει την ταχύτητα, τη θέση και το πλάτος των grains. 
SynthDef.new(\GranularStrLegato, {arg bufnum, amp=1.0; var tgrain, rateEnv, posEnv, ampEnv; ... }) 
Παράμετροι Buffer 
Καθορίζει τη διαδρομή του αρχείου και τα κανάλια για κάθε buffer. Χρησιμοποιεί το 's' ως αναφορά για τον server. 
s (Server), channels: 1 (Μονοφωνικός Ήχος) 
 

  

Κατά τη δημιουργία των διαφορετικών SynthDefs, με απασχόλησε το πώς να κάνω τον ήχο πιο "ζωντανό". Αυτό το πέτυχα προσθέτοντας τυχαίες παραμέτρους, όπως τη χρήση του `WhiteNoise.kr` για το panning, ώστε κάθε κόκκος (grain) να τοποθετείται τυχαία στον στερεοφωνικό χώρο. Επιπλέον, χρησιμοποίησα το αντικείμενο `EnvGen` για να ελέγξω την ένταση και τη διάρκεια κάθε κόκκου. 

Ένα ακόμα σημείο που με απασχόλησε ήταν το πώς να ενσωματώσω τον ρυθμό στη σύνθεση. Για αυτό το σκοπό, χρησιμοποίησα το `Task` για να δημιουργήσω βρόχους που θα έπαιζαν ρυθμούς με βάση τα δείγματα `PercDry.wav`. Προκειμένου να δημιουργήσω μια ενδιαφέρουσα ρυθμική ακολουθία, χρησιμοποίησα αντικείμενα όπως `Impulse` και `GrainBuf` για να ορίσω την ταχύτητα και τη διάρκεια των ρυθμικών στοιχείων. 

Για να βελτιώσω την εργασία και να δώσω έναν πιο εξελιγμένο χαρακτήρα στη σύνθεση, θα μπορούσα με τη χρήση του EnvGen να ελέγξω τη διακύμανση της συχνότητας των εφέ με την πάροδο του χρόνου. Αυτό θα πρόσθετε βάθος και κίνηση στον ήχο, κάνοντάς τον να αναπτύσσεται και να αλλάζει δυναμικά. Θα μπορούσα επισης να δημιουργήσω κλάσεις που αντιπροσωπεύουν κάθε στοιχείο της σύνθεσης, όπως τα διάφορα SynthDefs και εφέ. Αυτό θα μου επέτρεπε να οργανώσω τον κώδικα πιο αποτελεσματικά και να διευκολύνω τη διαχείριση πολύπλοκων ρυθμίσεων, κάνοντας τον κώδικα πιο ευανάγνωστο και επεκτάσιμο. 

Από αυτή την εργασία, αποκόμισα μια βαθύτερη κατανόηση του τρόπου με τον οποίο το SuperCollider διαχειρίζεται τον ήχο μέσω της γλώσσας προγραμματισμού του. Έμαθα πώς να χρησιμοποιώ τα **SynthDefs** για να ορίζω και να επεξεργάζομαι ήχους και πώς να οργανώνω τον κώδικά μου, χρησιμοποιώντας αντικειμενοστραφή προγραμματισμό και την αλληλεπίδραση μεταξύ αντικειμένων, μεθόδων, και μηνυμάτων. 

Επιπλέον, η μελέτη των βασικών αρχών προγραμματισμού, όπως αυτές παρουσιάζονται στο έργο του κυριου Ζάννου, με βοήθησε να κατανοήσω καλύτερα τις λειτουργίες της γλώσσας του SuperCollider και να οργανώσω τις ιδέες μου με πιο μεθοδικό τρόπο. Η προσέγγιση αυτή με δίδαξε όχι μόνο τις τεχνικές της γκρανουλαρικής σύνθεσης αλλά και πώς να σκέφτομαι προγραμματιστικά, αναλύοντας τα προβλήματα και δημιουργώντας λύσεις. 

Τέλος, η εργασία αυτή με έκανε να συνειδητοποιήσω τη δύναμη του SuperCollider ως ένα εργαλείο σύνθεσης και πειραματισμού. Η γνώση που αποκόμισα θα με βοηθήσει σε μελλοντικά πρότζεκτ, καθώς πλέον νιώθω πιο άνετη να εξερευνήσω πιο περίπλοκες μορφές ηχητικής σύνθεσης και προγραμματισμού. 

 

 

Βιβλιογραφια 

Cottle, David. (2011). "The SuperCollider Book."  

  

Zannos, Iannis. (2011). "Programming in SuperCollider." In "The SuperCollider Book." 

  

Ruviaro, Bruno. (2016). "A Gentle Introduction to SuperCollider." 
