package agents;

/**
 * Created by Abelether on 31/03/2016.
 */
public class agents {
    private int id;
    private String genome;
    private int speed;
    private double tot_energy;

    public agents (int $id, String $genome, int $speed, double enrgy)
    {
        id = $id;
        genome = $genome;
        speed = $speed;
        tot_energy = enrgy;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getGenome() {
        return genome;
    }

    public void setGenome(String genome) {
        this.genome = genome;
    }

    public int getSpeed() {
        return speed;
    }

    public void setSpeed(int speed) {
        this.speed = speed;
    }

    public double getTot_energy() {
        return tot_energy;
    }

    public void setTot_energy(double tot_energy) {
        this.tot_energy = tot_energy;
    }
}