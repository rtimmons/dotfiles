
public class Foo 
{
    public static void ohai(String...args)
    {
        for(String arg : args)
        {
            System.out.println(arg.toUpperCase());
        }        
    }
    public static void main(String[] args) 
    {
        ohai(args);
    }
}
