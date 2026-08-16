# IJCAI 2026 - Tutorial on Dynamical causal modelling
## A Bayesian computational framework for multi-scale hypothesis-testing  
This tutorial will teach the conceptual background and practical skills of mesoscopic model building in (human) neuroscience using DCM. We will focus on multi-modal hypothesis-testing with a concrete case study of how to link structural neural data (neurotransmitter) to functional electroencephalographic data. The taught skills are essential to utilise vast amounts of (openly-accessible) neural / biological data effectively for testing multi-scale hypothesis about structure-function relationships in (human) brains; it facilitates translational / pharmaceutical / medical, and computational research. 

Using the academic open-source freeware Statistical Parametric Mapping (SPM)[1,2], we demonstrate how to model human intracranial EEG in the frequency domain, and to test how neurotransmitter receptor data explains regional variations across the cortex [3,4]. For this, an established neural mass model - the canonical microcircuit (CMC)[5,6]-, variational Bayesian inference - dynamic causal modelling (DCM)[7,8]-, hierarchical hypothesis testing - parametric emirical Bayes (PEB)[9,10] -, and open source iEEG [11] and receptor density data [12] will be used. 

DCM is an established causal modelling technique in neuroscience, and it is widely used to test hypotheses related to neural imaging (functional magnetic resonance imaging (fMRI)) and electrophysiological data (magneto- / electroencephalography (M/EEG)). The technique is effective, as it relies on approximate Bayesian inference using variational Laplace, transparent and flexible, as an open source academic freeware which can be adjusted as needed, and it allows hierarchical hypothesis-testing via model specifications, priors, and group-level constraints.    

As the approach is efficient, flexible and adaptive, you will be able to model and explore many different datasets and hypotheses.

## Relevance
We present an effective, principled framework to integrate neural data and test any kind of hypothesis relating to mesoscopic functioning of the (human) brain. This is relevant for applied and theoretical (computational) clinical / medical / translational / pharmaceutical / biological researchers, who aim to understand mechanisms and dynamics in the brain, how dysfunctions are caused, and how, e.g., underlying neurobiology enables function and can be manipulated.

Further, (mesoscale) neuro-inspired architecture is more (energetically) efficient, causal, and capable than many current implementations of artificial intelligence. In that sense, theoretical / computational neuroscience offers insight about the implementation of natural intelligence and neural principles underlying cognitive processes [14,15].

## Software and data      
SPM [Download](https://www.fil.ion.ucl.ac.uk/spm/), [Documentation](https://www.fil.ion.ucl.ac.uk/spm/docs/) [1,2]

The SPM software is written in MathWorks MATLAB, and we will use MATLAB code. Therefore, to implement or run the code directly in the tutorial, a MATLAB license would be required. Please download and install the software to follow along (see also [1]).

Alternatives to using MATLAB:
- pre-compilled MATLAB SPM code and run via command line
- Octave as a free MATLAB alternative  
- SPM in Python, and adjusting the code in our example

Datasets:
- [normative iEEG data](https://mni-open-ieegatlas.research.mcgill.ca/) (Frauscher et al. 2018)[11]
- [autoradiography-derived receptor densities](https://www.frontiersin.org/journals/neuroanatomy/articles/10.3389/fnana.2017.00078/full#supplementaryMaterial) (Zilles and Palomero-Gallagher, 2017, Suppl. Table 2)[12]
- [mismatch negativity evoked response](https://www.fil.ion.ucl.ac.uk/spm/data/eeg_mmn/) (Garrido et al. 2007)[13]

Other M/EEG open datasets:
- Lists and databases: [Fieldtrip List](https://www.fieldtriptoolbox.org/faq/other/open_data/), [NeuroTechX List](https://github.com/NeuroTechX/awesome-bci#brain-databases), [OpenLists](https://openlists.github.io/data/), [OpenNeuro](https://openneuro.org/)
- [Review of some EEG databases](https://www.nature.com/articles/s41597-023-02614-0) (Subash et al. 2023, Nature Scientific Data)
- [EU neuro data sharing review](https://apertureneuro.org/article/144839-which-infrastructure-can-i-use-to-share-human-neuroimaging-data-a-survey-and-literature-review-on-current-solutions-for-eu-researchers) (Lefort-Besnard et al. 2025 Aperture Neuro (OHBM))

## Tutorial contents
### Theory and concepts (40 min)
- (generative) models and data modalities in neuroscience research: the purpose and types of in silico models in neuroscience are described, at which spatial scales they can be used, and which (where) data are available
- Mesoscopic models - neural mass model and canonical microcircuit: mesoscopic models offer (semi)mechanistic explanations as the combine neuroanatomical / -physiological specification with abstraction, which allows them to conceptually bridge the micro- to macro-scale; the reasoning and specification of the DCM canonical microcircuit as a meso-scale model are explained
- Dynamic causal modelling procedures - Bayes theorem, variational Laplace, hierarchical models: foundations of Bayesian modelling and inference are described and put in context to the DCM framework; it is explained how hypotheses are tested and models compared using hierarchical procedures

### Practical part (60 min)	
- Statistical parametric mapping (SPM) freeware / source code and DCM setup: general aspects of the freeware are outlined; a DCM model is setup, its data structure described, and relevant functions explained  
- Implementation of hierarchical hypotheses to constrain parameters: priors can be used to constrain or inform the inference, and therefore, we will give an overview of how this can be done in DCM to improve model fits
- Inference for baseline and prior-informed models: models with uninformed and neuroreceptor-informed priors are inferred, and it is explained how priors are effective in guiding the exploration of the evidence landscape  
- Model evaluation using the variational free energy (FE) (evidence lower bound): FE offers a principled metric to evaluate and compare models as it accounts for both accuracy and complexity; we will describe how this metric is used, and how modelling results can be reported 
- Bayesian model comparison, selection, reduction, and parametric group analyses: DCM offers effective comparison of multiple model / hypotheses; we will explain the procedure using practical examples

---

## References
#### Statistical parametric mapping
- [[1](https://joss.theoj.org/papers/10.21105/joss.08103)] Tierney, Tim M., Nicholas A. Alexander, John Ashburner, Nicole Labra Avila, Yaël Balbastre, Gareth Barnes, Yulia Bezsudnova, et al. 2025. “SPM 25: Open Source Neuroimaging Analysis Software.” Journal of Open Source Software 10 (110): 8103.
- [[2](https://www.fil.ion.ucl.ac.uk/spm/doc/books/spm/Statistical_Parametric_Mapping_The_Analysis_of_Functional_Brain_Images.pdf)] Friston, Karl, John Ashburner, Stefan Kiebel, Thomas Nichols, and William Penny. 2006. Statistical Parametric Mapping: The Analysis of Functional Brain Images. Edited by William Penny, Karl J. Friston, John T. Ashburner, Stefan J. Kiebel, and Thomas E. Nichols. San Diego, CA: Academic Press.

#### Modelling intracranial EEG and neurotransmitter receptors
- [[3](https://doi.org/10.1002/hbm.70463)] Baud, Maxime O., and Dimitri Van De Ville. 2026. “Synaptic Tuning of Brain Rhythms: From Chemical Signalling to Cortical Oscillations.” Human Brain Mapping 47 (2): e70463.
- [[4](https://doi.org/10.1002/hbm.70393)] Stoof, U. M., K. J. Friston, M. Tisdall, G. K. Cooray, and R. E. Rosch. 2025. “Topographic Variation in Human Neurotransmitter Receptor Densities Explains Differences in Intracranial EEG Spectra.” Human Brain Mapping 46 (16): e70393.

#### Dynamic causal modelling (DCM)
- [[5](https://doi.org/10.1016/j.neuroimage.2009.11.062)] Daunizeau, J., O. David, and K. E. Stephan. 2011. “Dynamic Causal Modelling: A Critical Review of the Biophysical and Statistical Foundations.” NeuroImage 58 (2): 312–22.
- [[6](https://doi.org/10.1016/s1053-8119(03)00202-7)] Friston, Karl J., L. Harrison, and W. Penny. 2003. “Dynamic Causal Modelling.” NeuroImage 19 (4): 1273–1302.

#### Parametric empirical Bayes (PEB)
- [[7](https://doi.org/10.1016/j.neuroimage.2015.11.015)] Friston, Karl J., Vladimir Litvak, Ashwini Oswal, Adeel Razi, Klaas E. Stephan, Bernadette C. M. van Wijk, Gabriel Ziegler, and Peter Zeidman. 2016. “Bayesian Model Reduction and Empirical Bayes for Group (DCM) Studies.” NeuroImage 128 (March): 413–31.
- [[8](https://doi.org/10.1016/j.neuroimage.2019.06.032)] Zeidman, Peter, Amirhossein Jafarian, Mohamed L. Seghier, Vladimir Litvak, Hayriye Cagnan, Cathy J. Price, and Karl J. Friston. 2019. “A Guide to Group Effective Connectivity Analysis, Part 2: Second Level Analysis with PEB.” NeuroImage 200 (October): 12–25.

#### Canonical microcircuit model (CMC)
- [[9](https://doi.org/10.1016/j.neuron.2012.10.038)] Bastos, André, W. Martin Usrey, Rick A. Adams, George R. Mangun, Pascal Fries, and Karl J. Friston. 2012. “Canonical Microcircuits for Predictive Coding.” Neuron 76 (4): 695–711.
- [[10](https://doi.org/10.3389/fncom.2013.00057)] Moran, Dimitris A. Pinotsis, and Karl J. Friston. 2013. “Neural Masses and Fields in Dynamic Causal Modeling.” Frontiers in Computational Neuroscience 7 (May): 57.

#### Normative intracranial EEG atlas
- [[11](https://doi.org/10.1093/brain/awy035)] Frauscher, Birgit, Nicolas von Ellenrieder, Rina Zelmann, Irena Doležalová, Lorella Minotti, André Olivier, Jeffery Hall, et al. 2018. “Atlas of the Normal Intracranial Electroencephalogram: Neurophysiological Awake Activity in Different Cortical Areas.” Brain: A Journal of Neurology 141 (4): 1130–44.

#### Autoradiography-derived neurotransmitter receptor densities
- [[12](https://doi.org/10.3389/fnana.2017.00078)] Zilles, Karl, and Nicola Palomero-Gallagher. 2017. “Multiple Transmitter Receptors in Regions and Layers of the Human Cerebral Cortex.” Frontiers in Neuroanatomy 11 (September): 78.

#### Mismatch negativity paradigm and DCM ERP model comparison
- [[13](https://www.sciencedirect.com/science/article/pii/S1053811907002273)] Garrido, Marta I., James M. Kilner, Stefan J. Kiebel, Klaas E. Stephan, and Karl J. Friston. 2007. “Dynamic Causal Modelling of Evoked Potentials: A Reproducibility Study.” NeuroImage 36 (3): 571–80.

#### Efficient computing with microciruits
- [[14](https://doi.org/10.1126/sciadv.adr6698)] George, Dileep, Miguel Lázaro-Gredilla, Wolfgang Lehrach, Antoine Dedieu, Guangyao Zhou, and Joseph Marino. 2025. “A Detailed Theory of Thalamic and Cortical Microcircuits for Predictive Visual Inference.” Science Advances 11 (6): eadr6698.
- [[15](https://doi.org/10.48550/arXiv.2508.06501.)] Douglas, P. K. 2025. “Computing with Canonical Microcircuits.” arXiv [q-Bio.NC]. arXiv.

