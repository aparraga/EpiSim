/**
 * Result holds a summary of timestamped values generated by the model at one time step
 */
public class Result {
  
  // List of Time Stamps associated with summary data
  private Time time;
  
  // Duration of Time associated with summary data
  private Time step;
  
  // Total People
  private int peopleTally;
  
  // Number of HospitalBeds
  private int numHospitalBeds;
  
  // Tally of compartment statuses itemized by pathogen and demographic
  private HashMap<Demographic, HashMap<Pathogen, HashMap<Compartment, Integer>>> compartmentTally;
  
  // Tally of symptom statuses itemized by pathogen and demographic
  private HashMap<Demographic, HashMap<Pathogen, HashMap<Symptom, Integer>>> symptomTally;
  
  // Tally of people hospitalizations itemized by pathogen and demographic
  private HashMap<Demographic, Integer> hospitalizedTally;
  
  // Average Social Encounters Per Demographic
  private HashMap<Demographic, Integer> encounterTally;
  
  // Average Trips Per Demographic
  private HashMap<Demographic, Integer> tripTally;
  
  /**
   * Constructor for Result()
   */
  public Result(CityModel model) {
    
    time = new Time();
    step = new Time();
    
    this.peopleTally  = 0;
    
    compartmentTally  = new HashMap<Demographic, HashMap<Pathogen, HashMap<Compartment, Integer>>>();
    symptomTally      = new HashMap<Demographic, HashMap<Pathogen, HashMap<Symptom, Integer>>>();
    hospitalizedTally = new HashMap<Demographic, Integer>();
    encounterTally    = new HashMap<Demographic, Integer>();
    tripTally         = new HashMap<Demographic, Integer>();
    
    // Initialize tallies with values of zero
    for(Demographic d : Demographic.values()) {
      HashMap<Pathogen, HashMap<Compartment, Integer>> cTally = new HashMap<Pathogen, HashMap<Compartment, Integer>>();
      HashMap<Pathogen, HashMap<Symptom, Integer>>     sTally = new HashMap<Pathogen, HashMap<Symptom, Integer>>();
      for(Pathogen p : model.getPathogens()) {
        HashMap<Compartment, Integer> cT = new HashMap<Compartment, Integer>();
        HashMap<Symptom, Integer>     sT = new HashMap<Symptom, Integer>();
        for(Compartment c : Compartment.values())
          cT.put(c, 0);
        for(Symptom s : Symptom.values())
          sT.put(s, 0);
        cTally.put(p, cT);
        sTally.put(p, sT);
      }
      this.compartmentTally.put(d, cTally);
      this.symptomTally.put(d, sTally);
      this.hospitalizedTally.put(d, 0);
      this.encounterTally.put(d, 0);
      this.tripTally.put(d, 0);
    }
  }
  
  /**
   * Set Time Stamp of model values
   *
   * @param t Time
   */
  public void setTime(Time t) {
    this.time = t;
  }
  
  /**
   * Get Time Stamp of model values
   */
  public Time getTime() {
    return this.time;
  }
  
  /**
   * Set Duration of time that passed to generate these values
   *
   * @param t Time
   */
  public void setTimeStep(Time t) {
    this.step = t;
  }
  
  /**
   * Get Duration of time that passed to generate these values
   */
  public Time getTimeStep() {
    return this.step;
  }
  
  /**
   * Add Person Stats to Tallies
   *
   * @param p Person
   */
  public void tallyPerson(Person person) {
    Demographic d = person.getDemographic();
    
    this.peopleTally++;
    
    if(person.hospitalized()) {
      int hTally = this.hospitalizedTally.get(d);
      this.hospitalizedTally.put(d, hTally + 1);
    }
      
    for(HashMap.Entry<Pathogen, PathogenEffect> entry : person.getStatusMap().entrySet()) {
      Pathogen pathogen = entry.getKey();
      PathogenEffect pE = entry.getValue();
      
      Compartment c = pE.getCompartment();
      int cTally = this.compartmentTally.get(d).get(pathogen).get(c);
      this.compartmentTally.get(d).get(pathogen).put(c, cTally+1);
      
      for(Symptom s : pE.getCurrentSymptoms()) {
        int sTally = this.symptomTally.get(d).get(pathogen).get(s);
        this.symptomTally.get(d).get(pathogen).put(s, sTally+1);
      }
    }
  }
  
  /**
   * Tally a single encounter
   *
   * @param p Person
   */
  public void tallyTrip(Person p) {
    Demographic d = p.getDemographic();
    int tTally = tripTally.get(d);
    tripTally.put(d, tTally + 1);
  }
  
  /**
   * Tally a single trip
   *
   * @param p Person
   */
  public void tallyEncounter(Person p1, Person p2) {
    Demographic d1 = p1.getDemographic();
    int p1Tally = tripTally.get(d1);
    tripTally.put(d1, p1Tally + 1);
    
    Demographic d2 = p2.getDemographic();
    int p2Tally = tripTally.get(d1);
    tripTally.put(d2, p2Tally + 1);
  }
  
  @Override
  public String toString() {
    return "Results at " + this.getTime();
  }
  
  /**
   * Get tally for specified compartment
   *
   * @param d Demographic
   * @param p Pathogen
   * @param c Compartment
   */
  public int getCompartmentTally(Demographic d, Pathogen p, Compartment c) {
    return this.compartmentTally.get(d).get(p).get(c);
  }
  
  /**
   * Get tally for specified symptom
   *
   * @param d Demographic
   * @param p Pathogen
   * @param s Symptom
   */
  public int getSymptomTally(Demographic d, Pathogen p, Symptom s) {
    return this.compartmentTally.get(d).get(p).get(s);
  }
  
  /**
   * Get tally for specified hospitalizations 
   *
   * @param d Demographic
   */
  public int getHospitalizedTally(Demographic d) {
    return this.hospitalizedTally.get(d);
  }
  
  /**
   * Get tally for specified encounters
   *
   * @param d Demographic
   */
  public int getEncounterTally(Demographic d) {
    return this.encounterTally.get(d);
  }
  
  /**
   * Get tally for specified trips
   *
   * @param d Demographic
   */
  public int getTripTally(Demographic d) {
    return this.tripTally.get(d);
  }
  
  /**
   * Get tally for people
   */
  public int getPeopleTally() {
    return this.peopleTally;
  }
  
  /**
   * Set number of Hospital Beds
   *
   * @param num
   */
  public void setHospitalBeds(int num) {
    this.numHospitalBeds = num;
  }
  
  /**
   * Get number of Hospital Beds
   */
  public int getHospitalBeds() {
    return this.numHospitalBeds;
  }
}